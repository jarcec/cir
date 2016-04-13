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
require 'cir'
require 'tmpdir'
require 'test/unit'
require 'fileutils'

##
# Parent test case that will contain shared functionality that we need
# across various test cases.
class CirTestCase < Test::Unit::TestCase

  ##
  # Prepare each test, currently:
  # * Forward stderr and stdout to /dev/null
  # * Prepare working directory (in tmp space)
  def setup
    # Create working directory
    @workDir = Dir.mktmpdir(["cir_test_", "_#{self.class.name}"])
    @repoDir = "#{@workDir}/repo"

    # Forward stderr/stdout to /dev/null to not mess with test output
    @original_stderr = $stderr
    @original_stdout = $stdout    
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end

  ##
  # Undo all the changes we did in #setup
  def teardown
    # Remove forwarding of stderr/stdout to /dev/null
    $stderr = @original_stderr
    $stdout = @original_stdout

    # Cleaning up working directory
    FileUtils.rm_rf(@workDir, secure: true)
  end

  ## 
  # Create new file with given file name inside the work directory
  # and return absolute path to the created file.
  def create_file(fileName, content)
    full_path = "#{@workDir}/#{fileName}"
    File.open(full_path, 'w') { |f| f.write(content) }
    File.expand_path(full_path)
  end

  ## 
  # Initialize Cir::Repository inside @repoDir and persist that inside
  # @repo variable (e.g. we have max 1 repo per test instance).
  def init_repo
    Cir::Repository.create(@repoDir)
    @repo = Cir::Repository.new(@repoDir)
  end

  ##
  # Initialize only git repository (no metadata) and persist that inside
  # @repo variable.
  def init_git_repo
    @repo = Cir::GitRepository.create(@repoDir)
  end

  ##
  # Asserts if given file have been correctly updated in the git working
  # directory.
  def assert_file_in_repo(file)
    diff = Cir::DiffManager.create(file, "#{@repDir}/#{file}")
    assert_false diff.changed?
  end
end
