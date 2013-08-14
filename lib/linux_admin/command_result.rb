class CommandResult
  attr_reader :output, :error, :exit_status

  def initialize(output, error, exit_status)
    @output      = output
    @error       = error
    @exit_status = exit_status
  end
end
