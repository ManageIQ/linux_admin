module LinuxAdmin
  class CredentialError < AwesomeSpawn::CommandResultError
    def initialize(result)
      super("Invalid username or password", result)
    end
  end
end
