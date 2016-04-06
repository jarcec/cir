require 'test/unit'
require 'rspec/mocks'
require 'cir'
require 'tempfile'

class TestCli < Test::Unit::TestCase

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
    @cli = Cir::Cli.new
    @repository = TestRepository.new
    @cli.set_repository @repository
  end

  def test_run_register_no_files
    assert_raise(SystemExit) { @cli.run(["register"]) }
  end

  def test_run_register
    Dir.mktmpdir("cir_test_cli_") do |dir|
      inputFile = "#{dir}/out.txt"
      File.open(inputFile, 'w') {|f| f.write("Input data") }

      @cli.run(["register", inputFile, inputFile])
      assert_equal @repository.db, [inputFile, inputFile]
    end
  end

end
