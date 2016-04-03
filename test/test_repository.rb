require 'tmpdir'
require 'test/unit'
require 'cir'

class RepositoryTest < Test::Unit::TestCase

  def test_create_already_exists
    Dir.mktmpdir("cir_test_repo_") do |repoDir|
      assert_raise Cir::Exception::RepositoryExists do
        Cir::Repository.create(repoDir)
      end
    end
  end

  def test_create
    Dir.mktmpdir("cir_test_repo_") do |baseDir|
      repoDir = "#{baseDir}/repo"
      Cir::Repository.create(repoDir)

      fileList = "#{repoDir}/cir.file_list.yml"

      assert File.exists? fileList
      yaml = YAML::Store.new(fileList)

      assert_equal(1, yaml.transaction { yaml[:version] })
      assert_equal({}, yaml.transaction { yaml[:files] })
    end
  end


  def test_register
    with_repo do |repoDir|
      Dir.mktmpdir("cir_test_input_") do |inputDir|
        # Prepare test file
        inputFile = "#{inputDir}/out.txt"
        File.open(inputFile, 'w') {|f| f.write("Input data") }

        # Register in repository
        repo = Cir::Repository.new(repoDir)
        repo.register(inputFile)

        # Which should create entity in the repository
        yaml = YAML::Store.new(repoDir + '/cir.file_list.yml')
        result = yaml.transaction { yaml[:files][inputFile] }
        assert_not_nil result
        assert_equal({}, result)

        # And the file should also exists in the working directory
        assert File.exists?("#{repoDir}/#{inputFile}")
      end
    end
  end

  def test_register_already_exists
    with_repo do |repoDir|
      Dir.mktmpdir("cir_test_input_") do |inputDir|
        # Prepare test file
        inputFile = "#{inputDir}/out.txt"
        File.open(inputFile, 'w') {|f| f.write("Input data") }

        # Register in repository
        repo = Cir::Repository.new(repoDir)
        repo.register(inputFile)

        # And register again
        assert_raise Cir::Exception::AlreadyRegistered do
          repo.register(inputFile)
        end
      end
    end
  end


  def test_registered
    with_repo do |repoDir|
      Dir.mktmpdir("cir_test_input_") do |inputDir|
        # Prepare test file
        inputFile = "#{inputDir}/out.txt"
        File.open(inputFile, 'w') {|f| f.write("Input data") }

        # Register in repository
        repo = Cir::Repository.new(repoDir)
        repo.register(inputFile)

        assert repo.registered?(inputFile)
        assert !repo.registered?("/blah")
      end
    end
  end

  def test_status
    with_repo do |repoDir|
      Dir.mktmpdir("cir_test_input_") do |inputDir|
        inputFile = "#{inputDir}/out.txt"
        File.open(inputFile, 'w') {|f| f.write("Input data") }
        inputFile2 = "#{inputDir}/out2.txt"
        File.open(inputFile2, 'w') {|f| f.write("Input data") }

        repo = Cir::Repository.new(repoDir)
        repo.register inputFile
        repo.register inputFile2

        # Everything
        status = repo.status
        assert_not_nil status
        assert_equal status.size, 2

        # Not registered file
        assert_raise(Cir::Exception::NotRegistered) { repo.status ["X"] }

        # One specific file
        status = repo.status [inputFile]
        assert_not_nil status
        assert_equal status.size, 1
      end
    end
  end

  # Helper method to automatically facilitate a new git repository for each test method
  def with_repo
    Dir.mktmpdir("cir_test_repo_") do |baseDir|
      repoDir = "#{baseDir}/repo"
      Cir::Repository.create(repoDir)
      yield(repoDir)
    end
  end


end
