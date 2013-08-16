class CommandResultError < StandardError
  attr_reader :result

  def initialize(message, result)
    super(message)
    @result = result
  end
end

class LinuxAdmin
  class CredentialError < CommandResultError
    def initialize(result)
      super("Invalid username or password", result)
    end
  end
end
