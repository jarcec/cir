module Cir
  module Exception
    ##
    # Thrown in case that we're initializing already existing repository
    class AlreadyRegistered < RuntimeError; end

    ##
    # Throw in case that we're trying to access non existing repository
    class RepositoryExists < RuntimeError; end
  end
end

