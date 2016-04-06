require 'trollop'
require 'cir/repository'

module Cir
  class Cli 

    SUB_COMMANDS = %w(init register status update)

    def initialize
      # Repository with all our metadata
      cirHome = File.expand_path(ENV['CIR_HOME'] || "~/.cir/repository")
      @repository = Cir::Repository.new(cirHome)
    end

    def set_repository(repository)
      @repository = repository
    end

    def run(argv)
      # Global argument parsing
      @global_opts = Trollop::options(argv) do
        version "CIR - Configs in repository 0.0.X-SNAPSHOT"
        banner "Keep your configuration files safely versioned in external repository. Available subcommands #{SUB_COMMANDS}"
        stop_on SUB_COMMANDS
      end
      
      # Subcommand specific argument parsing
      @cmd = argv.shift
      @cmd_opts = case @cmd
        when "init"
        when "register"
          Trollop::die "Missing file list" if argv.empty?
        when "status"
          Trollop::options(argv) do
            opt :show_diff, "Show diffs for changed files", :default => false
          end
        when "update"
          # Nothing specific for update
        else
          Trollop::die "Unknown subcommand #{cmd.inspect}"
      end

      # Special operation for new repository
      if @cmd == "init"
        Cir::Repository.create(cirHome)
        return
      end

      # Execute given action(s)
      case @cmd
      when "register"
        sub_register(argv)
      when "status"
        sub_status(argv)
      when "update"
        sub_update(argv)
      end
    end

    def sub_register(argv)
      argv.each do |file|
        puts "Registering file: #{file}"
        @repository.register(File.expand_path(file))
      end
    end

    def sub_status(argv)
      files = @repository.status(argv.empty? ? nil : argv)
      
      files.each do |file|
        diff = Cir::DiffManager.create(file)
        if diff.changed?
          puts "File #{file.file_path} changed."
          puts diff.to_s if @cmd_opts[:show_diff]
        end
      end
    end

    def sub_update(argv)
      @repository.update(argv.empty? ? nil : argv)
    end

    def self.run
      cli = Cli.new
      cli.run(ARGV)
    end
  end
end
