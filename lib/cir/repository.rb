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
    def self.create(rootPath)
      git = Cir::GitRepository.create(rootPath)

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
    def register(file)
      # Register is one time operation, one can't re-register existing file
      raise Cir::Exception::AlreadyRegistered, file if registered?(file)

      # Import file to repository
      import_file file

      # Create new metadata for the tracked file
      @database.transaction { @database[:files][file] = {} }

      # And finally commit the transaction
      @git.commit
    end

    ##
    # Deregister file
    def deregister(file)
      @database.transaction do
        stored = stored_file(file)

        # Remove the file from git, our database and finally from git working directory
        FileUtils.rm(stored.repository_location)
        @git.remove_file(file[1..-1]) # Removing leading "/" to make the absolute path relative to the repository's root
        @database[:files].delete(file)
      end

      # And finally commit the transaction
      @git.commit
    end


    ##
    # Returns true if given file is registered, otherwise false.
    def registered?(file)
      @database.transaction { return @database[:files][file] != nil }
    end

    ##
    # Return status for all registered files
    def status(requested_files = nil)
      files = []

      @database.transaction do 
        # Without requested_files list, we'll return everything
        if requested_files.nil?
          @database[:files].each do |key, value|
            files << stored_file(key)
          end
        else
          # Otherwise we'll look only for specific files
          requested_files.each do |request|
            files << stored_file(request)
          end
        end
      end

      files
    end


    ##
    # Will update stored variant of existing files with their newer copy
    def update(files = nil)
      @database.transaction do
        if files.nil?
          # No file list, go over all files and detect if they changed
          @database[:files].each do |key, value|
            stored = stored_file(key)

            diff = Cir::DiffManager.create(stored)
            if diff.changed?
              import_file key
            end
          end
        else
          # When we have a file list we will verify only the particular files
          files.each do |file|
            stored = stored_file(file)

            diff = Cir::DiffManager.create(stored)
            if diff.changed?
              import_file key
            end
          end
        end
      end

      # Finally commit the transaction
      @git.commit
    end

    ##
    # Restore persistent variant of the files
    def restore(files = nil, force = false)
      @database.transaction do
        if files.nil?
          # No file list, go over all files and detect if they changed
          @database[:files].each do |key, value|
            stored = stored_file(key)

            # If the file on local file system doesn't exists, task is simple - just copy it to working directory
            if not File.exists?(stored.file_path)
              FileUtils.cp(stored.repository_location, stored.file_path)
            else
              if Cir::DiffManager.create(stored).changed?
                if force
                  FileUtils.remove_entry stored.file_path
                  FileUtils.cp(stored.repository_location, stored.file_path)
                else
                  puts "Skipped mass change to #{key}."
                end
              end
            end
          end
        else
          # User supplied set of files
          files.each do |file|
            stored = stored_file(file)
            diff = Cir::DiffManager.create(stored)

            if not File.exists? stored.file_path
              FileUtils.cp(stored.repository_location, stored.file_path)
            else
              if diff.changed?
                FileUtils.remove_entry stored.file_path
                FileUtils.cp(stored.repository_location, stored.file_path)
              end
            end
          end
        end
      end
    end

    private

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

  end # end class Repository
end # end module Cir
