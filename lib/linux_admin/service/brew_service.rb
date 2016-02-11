# s = LinuxAdmin::Service.new("postgresql")
begin
  require 'bundler'
rescue LoaderException
end

module LinuxAdmin
  class BrewService < Service
    def running?
      # brew services list shows all the services running / installed
      ::Bundler.with_clean_env {
        Common.run(Common.cmd(:brew), :params => %w(services list))
          .output.split("\n").any? { |x| x.starts_with?("#{name} ") }
      }
    end

    def enable
      run_cmd!("start", name)
    end

    def disable
      run_cmd!("stop", name)
    end

    def start
      run_cmd!("start", name)
    end

    def stop
      run_cmd!("stop", name)
    end

    def restart
      # attempt to manually stop/start if restart fails
      unless run_cmd("restart", name)
        stop
        start
      end

      self
    end

    private

    def run_cmd(*actions)
      ::Bundler.with_clean_env { Common.run(Common.cmd(:brew), :params => %w(services) + actions).success? }
    end

    def run_cmd!(*actions)
      ::Bundler.with_clean_env { Common.run!(Common.cmd(:brew), :params => %w(services) + actions) }
      self
    end
  end
end
