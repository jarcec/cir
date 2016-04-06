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

  def test_deregister
    init_repo

    # Prepare test file
    test_file = create_file("A", "Input data")

    # Register in repository
    @repo.register(test_file)
    assert @repo.registered? test_file

    # Deregister the file now
    @repo.deregister(test_file)

    assert_false @repo.registered? test_file
    assert_false File.exists?("#{@repoDir}/#{test_file}")

    # Deregister of not registered file should raise an exception
    assert_raise(Cir::Exception::NotRegistered) { @repo.deregister "X"}
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

  def test_update
    init_repo

    test_file = create_file("A", "data")
    @repo.register(test_file)

    # Update non existing file
    assert_raise(Cir::Exception::NotRegistered) { @repo.update ["X"] }

    # Updating via "all"
    create_file("A", "New data")
    @repo.update
    assert_file_in_repo test_file

    # Updating via "given file"
    create_file("A", "Newer data")
    @repo.update
    assert_file_in_repo test_file
  end

  def test_restore
    init_repo

    test_file = create_file("A", "data")
    @repo.register(test_file)

    # Restore non existing file
    assert_raise(Cir::Exception::NotRegistered) { @repo.restore ["X"] }

    # Restoring non-existing file via "all"
    FileUtils.rm test_file
    @repo.restore
    assert_file_in_repo test_file

    # Restore non-existing file specifically by file name
    FileUtils.rm test_file
    @repo.restore([test_file])
    assert_file_in_repo test_file

    # Restoring via "all"
    create_file("A", "New data")
    @repo.restore(nil, true)
    assert_file_in_repo test_file

    # Restore given file
    create_file("A", "Newer data")
    @repo.restore([test_file])
    assert_file_in_repo test_file
  end

end
