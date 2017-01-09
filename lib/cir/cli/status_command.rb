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
    # Status command
    class StatusCommand < CommandWithRepository

      def opts
        Trollop::Parser.new do
          banner "Show status of registered files."
          opt :show_diff, "Show diffs for changed files", :default => false
          opt :all, "Display all files even those that haven't been changed", :default => false
        end
      end

      def process_with_repository
        files = self.repository.status(self.files.empty? ? nil : self.files)

        files.each do |file|
          diff = file.diff
          if diff.changed?
            puts "File #{file.file_path} changed."
            puts "#{diff.to_s}\n" if self.args[:show_diff]
          elsif self.args[:all]
            puts "File #{file.file_path} is the same."
          end
        end
      end
    end
  end
end
