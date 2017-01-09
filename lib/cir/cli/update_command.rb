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
    # Update command
    class UpdateCommand < CommandWithRepository

      def opts
        Trollop::Parser.new do
          banner "Note new local changes to the tracked file(s) in the repository (~ git commit)"
          opt :message, "Optional commit message that should be used when updating the changes in tracking git repository.", type: :string
        end
      end

      def process_with_repository
        Trollop::die "Missing file list" if self.files.empty?

        self.repository.update(self.files, {message: self.args.message})
      end

    end
  end
end
