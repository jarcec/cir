require 'tmpdir'
require 'cir_test_case'

class GitRepositoryTest < CirTestCase

  def test_create_already_exists
    assert_raise Cir::Exception::RepositoryExists do
      Cir::GitRepository.create(@workDir)
    end
  end

  def test_create
    Cir::GitRepository.create(@repoDir)
    assert Dir.exists? "#{@repoDir}/.git"
  end

  def test_add_file_and_commit
    init_git_repo

    file_a = create_file("repo/a.file", "Content")
    file_b = create_file("repo/b.file", "Content")

    @repo.add_file "a.file"
    @repo.add_file "b.file"
    @repo.commit

    ruggedRepo = Rugged::Repository.new(@repoDir)
    master = ruggedRepo.branches.first
    assert_equal "master", master.name
    assert_not_nil master.target

    tree = master.target.tree
    assert_not_nil tree
    assert_equal 2, tree.count
    assert_not_nil tree['a.file']
    assert_not_nil tree['b.file']
  end

end

