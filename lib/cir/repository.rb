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
      raise Cir::Exception::AlreadyRegistered, file if registered?(file)

      @git.import_file(file)
      @database.transaction { @database[:files][file] = {} }
      @git.commit
    end

    ##
    # Returns true if given file is registered, otherwise false.
    def registered?(file)
      @database.transaction { return @database[:files][file] != nil }
    end

    # TODO: Not really finished yet
    def status(file)
      @database.transaction do
        @database[:files][file]
      end
    end

  end # end class Repository
end # end module Cir
