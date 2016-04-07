
module Cir
  ##
  # Represents metadata about stored file.
  class StoredFile

    ##
    # Full file path of the original file location
    attr :file_path

    ##
    # Location in the repository with stored and versioned copy of the file
    attr :repository_location

    ##
    # Constructor that will optionally populate attributes
    def initialize(attrs = {})
      attrs.each do |attr, value|
        instance_variable_set "@#{attr}", value
      end
    end

    ##
    # Generate diff using DiffManager
    def diff
      Cir::DiffManager.create(repository_location, file_path)
    end
  end
end
