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

require 'cir/version'
require 'cir/exception/exceptions'

# "Core" libraries
require 'cir/diff_manager'
require 'cir/stored_file'
require 'cir/git_repository'
require 'cir/repository'

# Cli modules
require 'cir/cli/command'
require 'cir/cli/command_with_repository'
require 'cir/cli/init_command'
require 'cir/cli/status_command'
require 'cir/cli/register_command'
require 'cir/cli/deregister_command'
require 'cir/cli/update_command'
require 'cir/cli/restore_command'
require 'cir/cli/main'
