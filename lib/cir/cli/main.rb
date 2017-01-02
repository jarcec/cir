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
  module Cli
    class Main
      ##
      # Global commands
      COMMANDS = {
        'init'       => InitCommand,
        'status'     => StatusCommand,
        'register'   => RegisterCommand,
        'deregister' => DeregisterCommand,
        'update'     => UpdateCommand,
        'restore'    => RestoreCommand,
      }

      ##
      # Global arguments
      def global_opts
        Trollop::Parser.new do
          version "CIR - Configs in repository #{Cir::VERSION}"
          banner <<-EOS
CIR - Configs in repository

Keep your configuration files safely versioned in external repository.

Usage:
  cir command [command args]

Command is one of #{COMMANDS.keys}.

EOS
          stop_on COMMANDS.keys
        end
      end

      ##
      # Process given arguments and execute them
      def run(argv)
        begin
          # Parse global arguments
          global_opts.parse argv

          # Specific command (must exists)
          cmd_name = argv.shift
          raise Trollop::HelpNeeded, "" unless cmd_name

          # Given command that is current executed
          @cmd = COMMANDS[cmd_name].new

          # Finish parsing arguments
          @cmd.global_args = @global_opts
          @cmd.args = @cmd.opts.parse(argv)
          @cmd.files = argv

          # And finally run the command
          @cmd.process

        rescue Trollop::CommandlineError => e
          $stderr.puts "Error: #{e.message}."
          $stderr.puts "Try --help for help."
          exit(-1)
        rescue Trollop::HelpNeeded
          # Global arguments
          global_opts.educate

          # Help for each command
          COMMANDS.each do |name, cmd|
            puts "\nCommand :#{name}\n"
            cmd.new.opts.educate
          end

          exit
        rescue Trollop::VersionNeeded
          puts global_opts.version
          exit
         end
      end

    end
  end
end
