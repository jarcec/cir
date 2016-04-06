require 'rugged'

module Cir
  ##
  # Class wrapping underlying Git library (rugged) and making simple certain operations
  # that cir needs to do the most.
  class GitRepository

    ##
    # Create new git repository
    def self.create(rootPath)
      raise Cir::Exception::RepositoryExists, "Path #{rootPath} already exists." if Dir.exists?(rootPath)

      # Without remote we will create blank new repository
      Rugged::Repository.init_at(rootPath)

      # And return our own wrapper on top of the underlying Rugged object
      Cir::GitRepository.new(rootPath)
    end

    ##
    # Open given existing repository on disk. You might need to {#create} one if needed.
    def initialize(rootPath)
      @repo = Rugged::Repository.new(rootPath)
    end

    ##
    # Adds given file to index, so that it's properly tracked for next commit. This file *must* contain
    # local path relative to the root of working directory.
    def add_file(file)
      index = @repo.index
      index.add path: file, oid: (Rugged::Blob.from_workdir @repo, file), mode: 0100644
      index.write
    end

    ##
    # Remove given file from the repository. The path must have the same characteristics as it have
    # for #add_file method.
    def remove_file(file)
      index = @repo.index
      index.remove file
    end

    ##
    # Path to the root of the repository
    def repository_root
      File.expand_path(@repo.path + "/../")
    end

    ##
    # Commit all staged changes to the git repository
    def commit
      index = @repo.index
      commit_tree = index.write_tree @repo

      commit_author = { email: 'cir-auto-commit@nowhere.cz', name: 'cir', time: Time.now }
      Rugged::Commit.create @repo,
        author: commit_author,
        committer: commit_author,
        message: 'Committed by CIR automatically.',
        parents: @repo.empty? ? [] : [ @repo.head.target ].compact,
        tree: commit_tree,
        update_ref: 'HEAD'
    end

  end # class GitRepository
end # module Cir
