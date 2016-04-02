# Future ideas
# --offline
# --verbose
require 'trollop'
require 'cir/repository'

module Cir
  class Cli 

    SUB_COMMANDS = %w(init register status)

    def run
      # Global argument parsing
      @global_opts = Trollop::options do
        version "CIR - Configs in repository 0.0.X-SNAPSHOT"
        banner "Keep your configuration files safely versioned in external repository."
        stop_on SUB_COMMANDS
      end
      
      # Subcommand specific argument parsing
      @cmd = ARGV.shift
      @cmd_opts = case cmd
        when "init"
        when "register"
          Trollop::die "Missing file list" if ARGV.empty?
        when "status"
        else
          Trollop::die "Unknown subcommand #{cmd.inspect}"
      end

      # Repository with all our metadata
      cirHome = File.expand_path(ENV['CIR_HOME'] || "~/.cir/repository")

      # Special operation for new repository
      if @cmd == "init"
        Cir::Repository.create(cirHome)
        return
      end

      @repository = Cir::Repository.new(cirHome)

      # Execute given action(s)
      case @cmd
      when "register"
        sub_register
      when "status"
        sub_status
      end
    end

    def sub_register
      ARGV.each do |file|
        puts "Registering file: #{file}"
        @repository.register(File.expand_path(file))
      end
    end

    def sub_status
      # TODO
    end

    def self.run
      cli = Cli.new
      cli.run
    end
  end
end
