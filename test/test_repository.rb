require 'tmpdir'
require 'cir_test_case'

class RepositoryTest < CirTestCase 

  def test_create_already_exists
    assert_raise Cir::Exception::RepositoryExists do
      Cir::Repository.create(@workDir)
    end
  end

  def test_create
    init_repo

    fileList = "#{@repoDir}/cir.file_list.yml"

    assert File.exists? fileList
    yaml = YAML::Store.new(fileList)

    assert_equal(1, yaml.transaction { yaml[:version] })
    assert_equal({}, yaml.transaction { yaml[:files] })
  end


  def test_register
    init_repo

    # Prepare test file
    test_file = create_file("A", "Input data")

    # Register in repository
    @repo.register(test_file)

    # Which should create entity in the repository
    yaml = YAML::Store.new(@repoDir + '/cir.file_list.yml')
    result = yaml.transaction { yaml[:files][test_file] }
    assert_not_nil result
    assert_equal({}, result)

    # And the file should also exists in the working directory
    assert File.exists?("#{@repoDir}/#{test_file}")

    # Registering again should fail
    assert_raise Cir::Exception::AlreadyRegistered do
      @repo.register(test_file)
    end
  end

  def test_registered
    init_repo

    test_file = create_file("A", "Input data")

    @repo.register(test_file)

    assert @repo.registered?(test_file)
    assert_false @repo.registered?("/blah")
  end

  def test_status
    init_repo

    test_file_a = create_file("A", "data")
    test_file_b = create_file("B", "data")
    @repo.register(test_file_a)
    @repo.register(test_file_b)

    # Everything
    status = @repo.status
    assert_not_nil status
    assert_equal status.size, 2

    # Not registered file
    assert_raise(Cir::Exception::NotRegistered) { @repo.status ["X"] }

    # One specific file
    status = @repo.status [test_file_a]
    assert_not_nil status
    assert_equal status.size, 1
  end

end
