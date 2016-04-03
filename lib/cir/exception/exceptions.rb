module Cir
  module Exception
    ##
    # Thrown in case that we're initializing already existing repository
    class AlreadyRegistered < RuntimeError; end

    ##
    # Thrown in case that we're trying to access non existing repository
    class RepositoryExists < RuntimeError; end

    ##
    # Thrown if we're trying to work with file that haven't been registered
    class NotRegistered < RuntimeError; end
  end
end

