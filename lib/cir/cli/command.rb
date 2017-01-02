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

module Cir
  module Cli
    ##
    # Wrapper class describing general command
    class Command

      ##
      # Attributes for parsed command line arguments
      attr_accessor :global_args, :args, :files

      ##
      # Initiation of the object will get CIR_HOME
      def initialize
        @cirHome = File.expand_path(ENV['CIR_HOME'] || "~/.cir/repository")
      end

      ##
      # Parameter parser for this command
      def opts
      end

      ##
      # Process given command with both global and command specific arguments on top of given files
      def process
      end
    end
  end
end