class CommandResultError < StandardError
  attr_reader :result

  def initialize(message, result)
    super(message)
    @result = result
  end
end

class LinuxAdmin
  class NoSuchFileError < Errno::ENOENT
    def initialize(message)
      super(message.split("No such file or directory -").last.split(" ").first)
    end

    def self.detected?(message)
      message.start_with?("No such file or directory -")
    end
  end

  class CredentialError < CommandResultError
    def initialize(result)
      super("Invalid username or password", result)
    end
  end
end
