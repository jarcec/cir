require 'trollop'
require 'cir/repository'

module Cir
  ##
  # Main command line interface for cir
  class Cli 

    # All subcommands that we're accepting
    SUB_COMMANDS = %w(init register status update deregister)

    ##
    # Initialization will create repository instance and hence validate that it exists
    def initialize
      # Repository with all our metadata
      cirHome = File.expand_path(ENV['CIR_HOME'] || "~/.cir/repository")
      @repository = Cir::Repository.new(cirHome)
    end

    ##
    # Override internal repository instance (only for test)
    def set_repository(repository)
      @repository = repository
    end

    ##
    # Process given arguments and execute them
    def run(argv)
      # Global argument parsing
      @global_opts = Trollop::options(argv) do
        version "CIR - Configs in repository #{Cir::VERSION}"
        banner "Keep your configuration files safely versioned in external repository. Available subcommands #{SUB_COMMANDS}"
        stop_on SUB_COMMANDS
      end
      
      # Subcommand specific argument parsing
      @cmd = argv.shift
      @cmd_opts = case @cmd
        when "init"
          sub_init
        when "register"
          Trollop::die "Missing file list" if argv.empty?
          sub_register(argv)
        when "deregister"
          Trollop::die "Missing file list" if argv.empty?
          sub_deregister(argv)
        when "status"
          Trollop::options(argv) do
            opt :show_diff, "Show diffs for changed files", :default => false
            opt :all, "Display all files even those that haven't been changed", :default => false
          end
          sub_status(argv)
        when "update"
          sub_update(argv)
        when "restore"
          sub_restore(argv)
        else
          Trollop::die "Unknown subcommand #{cmd.inspect}"
      end
    end

    ##
    # Init repository in new location
    def sub_init
      Cir::Repository.create(cirHome)
      return
    end

    ##
    # Register new file(s)
    def sub_register(argv)
      @repository.register(argv)
    end

    ##
    # Deregister existing file(s)
    def sub_deregister(argv)
      @repository.deregister(argv)
    end

    ##
    # Retrieve status of given file(s)
    def sub_status(argv)
      files = @repository.status(argv.empty? ? nil : argv)
      
      files.each do |file|
        diff = file.diff
        if diff.changed?
          puts "File #{file.file_path} changed."
          puts diff.to_s if @cmd_opts[:show_diff]
        elsif @cmd_opts[:all]
          puts "File #{file.file_path} is the same."
        end
      end
    end

    ##
    # Update given file(s) - e.g. commit any user changes
    def sub_update(argv)
      @repository.update(argv.empty? ? nil : argv)
    end

    ##
    # Restore given file(s) - e.g. get rid of any user changes
    def sub_restore(argv)
      @repository.restore(argv.empty? ? nil : argv)
    end

    ##
    # Convenience method to run the CLI without standalone instance
    def self.run
      cli = Cli.new
      cli.run(ARGV)
    end
  end
end
