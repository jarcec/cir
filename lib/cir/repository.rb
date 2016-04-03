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

      # Copy new file to the repository
      target_dir = File.expand_path(@git.repository_root + "/" + File.dirname(file))
      FileUtils.mkdir_p(target_dir)
      FileUtils.cp(file, target_dir)

      # And register it inside git and our metadata database
      @git.add_file(file[1..-1]) # Removing leading "/" to make the absolute path relative to the repository's root
      @database.transaction { @database[:files][file] = {} }

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
        @database[:files].each do |key, value|
          # Skip if we're searching for particular file(s)
          next if requested_files != nil and not requested_files.include? key

          # Otherwise create and populate StoredFile structure
          files << Cir::StoredFile.new(
            file_path: key,
            repository_location: File.expand_path(@git.repository_root + "/" + key)
          )
        end
      end

      files
    end

  end # end class Repository
end # end module Cir
