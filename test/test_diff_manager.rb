require 'tmpdir'
require 'test/unit'
require 'cir'

class DiffManagerTest < Test::Unit::TestCase

  def test_create
    Dir.mktmpdir("cir_diff_manager") do |dir|
      # The same files
      createFile("#{dir}/fileA", "A")
      createFile("#{dir}/fileB", "A")
      diff = Cir::DiffManager.create(Cir::StoredFile.new(file_path: "#{dir}/fileA", repository_location: "#{dir}/fileB"))
      assert_false diff.changed?

      # Different files
      createFile("#{dir}/fileC", "B")
      diff = Cir::DiffManager.create(Cir::StoredFile.new(file_path: "#{dir}/fileA", repository_location: "#{dir}/fileC"))
      assert diff.changed?
    end
  end


  # Create new file with given content
  def createFile(file, content)
    File.open(file, 'w') { |f| f.write(content) }
  end

end
