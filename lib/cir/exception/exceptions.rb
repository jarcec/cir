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
  module Exception
    ##
    # Thrown in case that we're initializing already existing repository
    class AlreadyRegistered < RuntimeError; end

    ##
    # Thrown in case that we're trying to access non existing repository
    class RepositoryExists < RuntimeError; end

    ##
    # Thrown if we're trying to work with file that haven't been registered
    class NotRegistered < RuntimeError; end
  end
end

