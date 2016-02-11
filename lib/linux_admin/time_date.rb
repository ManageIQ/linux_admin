module LinuxAdmin
  class TimeDate
    extend Common
    COMMAND = 'timedatectl'

    TimeCommandError = Class.new(StandardError)

    def self.system_timezone_detailed
      result = run!(cmd(COMMAND), :params => ["status"])
      result.output.split("\n").each do |l|
        return l.split(':')[1].strip if l =~ /Time.*zone/
      end
    rescue AwesomeSpawn::CommandResultError, AwesomeSpawn::NoSuchFileError
      Time.now.zone
    end

    def self.system_timezone
      system_timezone_detailed.split[0]
    end

    def self.system_time=(time)
      run!(cmd(COMMAND), :params => ["set-time", "#{time.strftime("%F %T")}", :adjust_system_clock])
    rescue AwesomeSpawn::CommandResultError => e
      raise TimeCommandError, e.message
    end

    def self.system_timezone=(zone)
      run!(cmd(COMMAND), :params => ["set-timezone", zone])
    rescue AwesomeSpawn::CommandResultError => e
      raise TimeCommandError, e.message
    end
  end
end
