require 'cir_test_case'

# This test case is not fully covering functionality in Cir::Cli
class TestCli < CirTestCase

  class TestRepository
    def register(file)
      @db ||= []
      @db << file
    end

    def db
      @db
    end
  end

  def setup
    super
    @cli = Cir::Cli.new
    @repository = TestRepository.new
    @cli.set_repository @repository
  end

  def test_run_register_no_files
    assert_raise(SystemExit) { @cli.run(["register"]) }
  end

  def test_run_register
    test_file = create_file("a.txt", "content")

    @cli.run(["register", test_file, test_file])
    assert_equal @repository.db, [test_file, test_file]
  end

end
