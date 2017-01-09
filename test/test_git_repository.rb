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

  def test_clone
    init_git_repo

    # Create some files in the first repo
    create_file("repo/a.file", "Content")
    @repo.add_file "a.file"
    @repo.commit

    # Create Cloned repository
    clonedRepoPath = "#{@workDir}/cloned"
    Cir::GitRepository.create(clonedRepoPath, remote: @repoDir)
    clonedRepo = Rugged::Repository.new(clonedRepoPath)

    # Validate that it exists properly and that it have the cloned file
    assert Dir.exists? "#{clonedRepoPath}/.git"
    master = clonedRepo.branches.first
    assert_equal "master", master.name
    assert_not_nil master.target

    assert_match(/a\.file/, master.target.message)

    tree = master.target.tree
    assert_not_nil tree
    assert_equal 1, tree.count
    assert_not_nil tree['a.file']
  end

  def test_add_file_and_commit
    init_git_repo

    create_file("repo/a.file", "Content")
    create_file("repo/b.file", "Content")

    @repo.add_file "a.file"
    @repo.commit
    @repo.add_file "b.file"
    @repo.commit

    ruggedRepo = Rugged::Repository.new(@repoDir)
    master = ruggedRepo.branches.first
    assert_equal "master", master.name
    assert_not_nil master.target

    assert_no_match(/a\.file/, master.target.message)
    assert_match(   /b\.file/, master.target.message)

    tree = master.target.tree
    assert_not_nil tree
    assert_equal 2, tree.count
    assert_not_nil tree['a.file']
    assert_not_nil tree['b.file']
  end

  def test_remove_file_and_commit
    init_git_repo

    ruggedRepo = Rugged::Repository.new(@repoDir)

    create_file("repo/a.file", "Content")
    @repo.add_file "a.file"
    @repo.commit
    assert_equal 1, ruggedRepo.branches.first.target.tree.count

    @repo.remove_file("a.file")
    @repo.commit
    assert_equal 0, ruggedRepo.branches.first.target.tree.count
  end

  def test_commit_message
    init_git_repo

    ruggedRepo = Rugged::Repository.new(@repoDir)

    # Default commit message starts with "Affected files"
    create_file("repo/a.file", "Content")
    @repo.add_file "a.file"
    @repo.commit
    assert_match "Affected files", ruggedRepo.branches.first.target.message

    # Which can be overridden to arbitrary text
    @repo.remove_file "a.file"
    @repo.commit("My message")
    assert_match "My message", ruggedRepo.branches.first.target.message
  end


end

