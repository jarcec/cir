require 'cir_test_case'

class StoredFileTest < CirTestCase

  def test_initialize
    file = Cir::StoredFile.new file_path: "/home/jarcec/", repository_location: "location" 
    assert_equal file.file_path, "/home/jarcec/"
    assert_equal file.repository_location, "location"
  end

end
