module LinuxAdmin
  class TimeDate
    extend Common
    COMMAND = 'timedatectl'

    def self.timezone
      result = run(cmd(COMMAND), :params => ["status"])
      result.output.split("\n").each do |l|
        return l.split(':')[1].strip if l =~ /Time.*zone/
      end
    end

    def self.set_system_time(time)
      run!(cmd(COMMAND), :params => ["set-time", "#{time.strftime("%F %T")}", :adjust_system_clock])
    end

    def self.set_system_timezone(location, city)
      run!(cmd(COMMAND), :params => ["set-timezone", "#{location}/#{city}"])
    end
  end
end
