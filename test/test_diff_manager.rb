require 'cir_test_case'

class DiffManagerTest < CirTestCase

  def test_create
    # Test files
    file_a = create_file("a.file", "A")
    file_b = create_file("b.file", "A")
    file_c = create_file("c.file", "B")

    # Same content
    diff = Cir::DiffManager.create(Cir::StoredFile.new(file_path: file_a, repository_location: file_b))
    assert_false diff.changed?

    # Different content
    diff = Cir::DiffManager.create(Cir::StoredFile.new(file_path: file_a, repository_location: file_c))
    assert diff.changed?
  end

end
