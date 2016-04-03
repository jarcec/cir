require 'tmpdir'
require 'test/unit'
require 'cir'

class GitRepositoryTest < Test::Unit::TestCase

  def test_create_already_exists
    Dir.mktmpdir("cir_test_repo_") do |repoDir|
      assert_raise Cir::Exception::RepositoryExists do
        Cir::GitRepository.create(repoDir)
      end
    end
  end

  def test_create
    Dir.mktmpdir("cir_test_repo_") do |baseDir|
      repoDir = "#{baseDir}/repo"
      Cir::GitRepository.create(repoDir)

      assert Dir.exists? "#{baseDir}/repo/.git"
    end
  end

  def test_add_file_and_commit
    with_repo do |baseDir, repo|
      createFile baseDir + "/repo/a.file", "file a"
      createFile baseDir + "/repo/b.file", "file b"
      repo.add_file "a.file"
      repo.add_file "b.file"
      repo.commit

      ruggedRepo = Rugged::Repository.new(baseDir + "/repo")
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

  # Helper method to automatically facilitate a new git repository for each test method
  def with_repo
    Dir.mktmpdir("cir_test_repo_") do |baseDir|
      repoDir = "#{baseDir}/repo"
      repo = Cir::GitRepository.create(repoDir)
      assert Dir.exists? "#{baseDir}/repo/.git"
      yield(baseDir, repo)
    end
  end

  # Create new file with given content
  def createFile(file, content)
    File.open(file, 'w') { |f| f.write(content) }
  end

end

