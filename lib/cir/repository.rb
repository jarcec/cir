# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'yaml/store'

module Cir
  ##
  # Main database with tracked files and such.
  class Repository
    ##
    # Outside of the git repository we also have separate database of all files that we're tracking with
    # additional metadata stored in this yaml file.
    FILE_LIST = 'cir.file_list.yml'

    ##
    # Create new repository backend (initialize git repo and the metadata database)
    #
    # Options
    #   :remote -> Optional remote URL that should be cloned
    def self.create(rootPath, options = {})
      git = Cir::GitRepository.create(rootPath, options)

      # Create database
      database = YAML::Store.new(rootPath + '/' + FILE_LIST)
      database.transaction do
        database[:version] = 1
        database[:files] = {} 
      end

      # Add it to git and finish
      git.add_file FILE_LIST
      git.commit
    end

    ##
    # Load repository (must exists) from given path.
    def initialize(rootPath)
      # Database with files and their characteristics
      @git = Cir::GitRepository.new(rootPath)
      @database = YAML::Store.new(rootPath + '/' + FILE_LIST)
    end

    ##
    # Register new file. Given path must be absolute.
    #
    # Options
    #   :message -> optional git message that should be used
    def register(files, options = {})
      expand(files) do |file|
        # Register is one time operation, one can't re-register existing file
        raise Cir::Exception::AlreadyRegistered, file if registered?(file)

        # Import file to repository
        import_file file

        # Create new metadata for the tracked file
        @database.transaction { @database[:files][file] = {} }

        puts "Registering file: #{file}"
      end

      # And finally commit the transaction
      @git.commit(options[:message])
    end

    ##
    # Deregister file
    #
    # Options
    #   :message -> optional git message that should be used
    def deregister(files, options = {})
      @database.transaction do
        expand(files) do |file|
          stored = stored_file(file)

          # Remove the file from git, our database and finally from git working directory
          FileUtils.rm(stored.repository_location)
          @git.remove_file(file[1..-1]) # Removing leading "/" to make the absolute path relative to the repository's root
          @database[:files].delete(file)

          puts "Deregistering file: #{file}"
        end
      end

      # And finally commit the transaction
      @git.commit(options[:message])
    end


    ##
    # Returns true if given file is registered, otherwise false.
    def registered?(file)
      @database.transaction { return @database[:files][file] != nil }
    end

    ##
    # Return status for all registered files
    def status(requested_files = nil)
      generate_file_list(requested_files)
    end


    ##
    # Will update stored variant of existing files with their newer copy
    #
    # Options
    #   :message -> optional git message that should be used
    def update(requested_files = nil, options = {})
      generate_file_list(requested_files).each do |file|
        if file.diff.changed?
          import_file(file.file_path)
          puts "Updating #{file.file_path}"
        end
      end

      # Finally commit the transaction
      @git.commit(options[:message])
    end

    ##
    # Restore persistent variant of the files
    def restore(requested_files = nil, force = false)
      generate_file_list(requested_files).each do |file|
        # If the destination file doesn't exist, we will simply copy it over
        if not File.exists?(file.file_path)
          FileUtils.cp(file.repository_location, file.file_path)
          puts "Restoring #{file.file_path}"
          next
        end

        # Skipping files that did not changed
        next unless file.diff.changed?

        # If we're run with force or in case of specific files, remove existing file and replace it
        if force or not requested_files.nil?
          FileUtils.remove_entry(file.file_path)
          FileUtils.cp(file.repository_location, file.file_path)
          puts "Restoring #{file.file_path}"
        else
          puts "Skipped mass change to #{key}."
        end
      end
    end

    private

    ##
    # Prepare file list for commands that accepts multiple files or none at all
    def generate_file_list(requested_files)
      files = []

      @database.transaction do
        if requested_files.nil?
          # No file list, go over all files and detect if they changed
          @database[:files].each { |file, value| files << stored_file(file) }
        else
          # User supplied set of files
          expand(requested_files) { |file| files << stored_file(file) }
        end
      end

      files
    end

    # Create stored file entity for given file (full path)
    def stored_file(file)
      raise Cir::Exception::NotRegistered, file unless @database[:files].include? file

      return Cir::StoredFile.new(
        file_path: file,
        repository_location: File.expand_path(@git.repository_root + "/" + file)
      )
    end

    ##
    # Import given file to git repository and add it to index
    def import_file(file)
      target_file = File.expand_path(@git.repository_root + "/" + file)
      target_dir = File.dirname(target_file)

      if File.exists?(target_file)
        FileUtils.rm_rf(target_file, secure: true)
      else
        FileUtils.mkdir_p(target_dir)
      end

      # And finally copy the file to repository
      FileUtils.cp(file, target_file)

      # And register it inside git and our metadata database
      @git.add_file(file[1..-1]) # Removing leading "/" to make the absolute path relative to the repository's root
    end

    ##
    # Loop over user specified file paths that will always expand the specified path
    def expand(files)
      files.each do |file|
        expanded = File.expand_path(file)
        yield expanded
      end
    end
  end # end class Repository
end # end module Cir
