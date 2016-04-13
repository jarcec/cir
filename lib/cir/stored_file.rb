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
  ##
  # Represents metadata about stored file.
  class StoredFile

    ##
    # Full file path of the original file location
    attr :file_path

    ##
    # Location in the repository with stored and versioned copy of the file
    attr :repository_location

    ##
    # Constructor that will optionally populate attributes
    def initialize(attrs = {})
      attrs.each do |attr, value|
        instance_variable_set "@#{attr}", value
      end
    end

    ##
    # Generate diff using DiffManager
    def diff
      Cir::DiffManager.create(repository_location, file_path)
    end
  end
end
