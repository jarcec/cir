require 'diffy'

module Cir
  ##
  # Abstraction above chosen diff library so that we can switch it at runtime if/when needed
  class DiffManager

    def self.create(source, destination)
      # Compare stored version in our internal repo and then the current version
      diff = Diffy::Diff.new(source, destination, source: "files", diff: "-U 3")

      # And finally return diff object with standardized interface
      DiffManager.new(diff)
    end

    private

    ##
    # Persist generated diff inside the class
    def initialize(diff)
      @diff = diff
    end

    public

    ##
    # Return true if the files are different (e.g. diff is non-empty)
    def changed?
      return !@diff.to_s.empty?
    end

    ##
    # Serialize the diff into string that can be printed to the console
    def to_s
      # We want nice colors by default
      @diff.to_s(:color)
    end

  end # class DiffManager
end # module Cir
