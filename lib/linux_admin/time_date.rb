module LinuxAdmin
  class TimeDate
    COMMAND = 'timedatectl'

    TimeCommandError = Class.new(StandardError)

    def self.system_timezone_detailed
      result = Common.run(Common.cmd(COMMAND), :params => ["status"])
      result.output.split("\n").each do |l|
        return l.split(':')[1].strip if l =~ /Time.*zone/
      end
    end

    def self.system_timezone
      system_timezone_detailed.split[0]
    end

    def self.timezones
      result = Common.run!(Common.cmd(COMMAND), :params => ["list-timezones"])
      result.output.split("\n")
    rescue AwesomeSpawn::CommandResultError => e
      raise TimeCommandError, e.message
    end

    def self.system_time=(time)
      Common.run!(Common.cmd(COMMAND), :params => ["set-time", "#{time.strftime("%F %T")}", :adjust_system_clock])
    rescue AwesomeSpawn::CommandResultError => e
      raise TimeCommandError, e.message
    end

    def self.system_timezone=(zone)
      Common.run!(Common.cmd(COMMAND), :params => ["set-timezone", zone])
    rescue AwesomeSpawn::CommandResultError => e
      raise TimeCommandError, e.message
    end
  end
end
