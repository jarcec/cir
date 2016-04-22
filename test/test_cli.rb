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
require 'cir_test_case'

# This test case is not fully covering functionality in Cir::Cli
class TestCli < CirTestCase

  class TestRepository
    def register(file, options = {})
      @db ||= []
      @db << file
      @options = options
    end

    def deregister(file, options = {})
      register(file, options)
    end

    def update(file, options = {})
      register(file, options)
    end

    def restore(file)
      register(file)
    end

    def db
      db = @db
      @db = []
      db
    end

    def options
      @options
    end
  end

  def setup
    super
    @cli = Cir::Cli.new
    @repository = TestRepository.new
    @cli.set_repository @repository
  end

  def test_run_register
    test_file = create_file("a.txt", "content")

    # Register two files
    @cli.run(["register", test_file, test_file])
    assert_equal @repository.db, [[test_file, test_file]]

    # Registering no files
    assert_raise(SystemExit) { @cli.run(["register"]) }
  end

  def test_run_deregister
    test_file = create_file("a.txt", "content")

    # Register two files
    @cli.run(["deregister", test_file, test_file])
    assert_equal @repository.db, [[test_file, test_file]]

    # Registering no files
    assert_raise(SystemExit) { @cli.run(["deregister"]) }
  end

  def test_run_update
    test_file = create_file("a.txt", "content")

    @cli.run(["update", test_file, test_file])
    assert_equal @repository.db, [[test_file, test_file]]

    @cli.run(["update"])
    assert_equal @repository.db, [nil]
  end

  def test_run_restore
    test_file = create_file("a.txt", "content")

    @cli.run(["restore", test_file, test_file])
    assert_equal @repository.db, [[test_file, test_file]]

    @cli.run(["restore"])
    assert_equal @repository.db, [nil]
  end

  def test_run_no_args
    @cli.run []
  end

  ##
  # Test that we're properly propagating message everywhere where it's needed
  def test_message
    # Register
    @cli.run ["register", "--message", "A", "file1" ]
    assert_equal @repository.options, { message: "A" }

    # Deregister
    @cli.run ["deregister", "--message", "A", "file2" ]
    assert_equal @repository.options, { message: "A" }

    # Update
    @cli.run ["update", "--message", "A", "file2" ]
    assert_equal @repository.options, { message: "A" }
  end
end
