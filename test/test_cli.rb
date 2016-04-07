require 'cir_test_case'

# This test case is not fully covering functionality in Cir::Cli
class TestCli < CirTestCase

  class TestRepository
    def register(file)
      @db ||= []
      @db << file
    end

    def deregister(file)
      register(file)
    end

    def update(file)
      register(file)
    end

    def restore(file)
      register(file)
    end

    def db
      db = @db
      @db = []
      db
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

end
