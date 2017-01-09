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
    # Init command
    class InitCommand < Command

      def opts
        Trollop::Parser.new do
          banner 'Initialize all internal structures in $CIR_HOME.'

          opt :clone, "Optional URL with repository that should be cloned", type: :string
        end
      end

      def process
        Cir::Repository.create(@cirHome, {remote: self.args[:clone]})
      end
    end
  end
end
