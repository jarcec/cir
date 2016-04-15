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
require 'trollop'
require 'cir/repository'

module Cir
  ##
  # Main command line interface for cir
  class Cli 

    # All subcommands that we're accepting
    SUB_COMMANDS = %w(init register status update deregister)

    ##
    # Initiation of the object will get CIR_HOME
    def initialize
      @cirHome = File.expand_path(ENV['CIR_HOME'] || "~/.cir/repository")
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

      # Subcommand init is kind of special as it works without existing repository
      if @cmd == "init"
        sub_init
        return
      end

      # For all our other commands we need to have repository available
      @repository ||= Cir::Repository.new(@cirHome)

      # Based on the subcommand parse additional arguments/execute given action
      case @cmd
        when "register"
          Trollop::die "Missing file list" if argv.empty?
          sub_register(argv)
        when "deregister"
          Trollop::die "Missing file list" if argv.empty?
          sub_deregister(argv)
        when "status"
          @cmd_opts = Trollop::options(argv) do
            opt :show_diff, "Show diffs for changed files", :default => false
            opt :all, "Display all files even those that haven't been changed", :default => false
          end
          sub_status(argv)
        when "update"
          sub_update(argv)
        when "restore"
          sub_restore(argv)
        else
          Trollop::educate
          Trollop::die "Unknown subcommand #{@cmd.inspect}"
      end
    end

    ##
    # Init repository in new location
    def sub_init
      Cir::Repository.create(@cirHome)
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
