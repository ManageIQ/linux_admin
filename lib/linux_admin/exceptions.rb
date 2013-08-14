class CommandResultError < StandardError
  attr_reader :result

  def initialize(message, result)
    super(message)
    @result = result
  end
end