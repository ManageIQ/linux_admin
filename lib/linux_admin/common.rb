require 'shellwords'

class LinuxAdmin
  module Common
    def cmd(cmd)
      Distro.local.class::COMMANDS[cmd]
    end

    def run(cmd, options = {})
      params = options[:params] || options[:parameters]

      launch_params = {}
      launch_params[:chdir] = options[:chdir] if options[:chdir]

      output = ""
      error  = ""
      status = nil

      begin
        output, error = launch(build_cmd(cmd, params), launch_params)
        status = exitstatus
      ensure
        output ||= ""
        error  ||= ""
        self.exitstatus = nil
      end
    rescue Errno::ENOENT => err
      raise NoSuchFileError.new(err.message) if NoSuchFileError.detected?(err.message)
      raise
    else
      CommandResult.new(output, error, status)
    end

    def run!(cmd, options = {})
      params = options[:params] || options[:parameters]
      command_result = run(cmd, options)

      if command_result.exit_status != 0
        message = "#{cmd} exit code: #{command_result.exit_status}"
        raise CommandResultError.new(message, command_result)
      end

      command_result
    end

    private

    def sanitize(params)
      return [] if params.blank?
      params.collect do |k, v|
        v = case v
            when Array;    v.collect {|i| i.to_s.shellescape}
            when NilClass; v
            else           v.to_s.shellescape
            end
        [k, v]
      end
    end

    def assemble_params(sanitized_params)
      sanitized_params.collect do |pair|
        pair_joiner = pair.first.try(:end_with?, "=") ? "" : " "
        pair.flatten.compact.join(pair_joiner)
      end.join(" ")
    end

    def build_cmd(cmd, params = nil)
      return cmd if params.blank?
      "#{cmd} #{assemble_params(sanitize(params))}"
    end

    # IO pipes have a maximum size of 64k before blocking,
    # so we need to read and write synchronously.
    # http://stackoverflow.com/questions/13829830/ruby-process-spawn-stdout-pipe-buffer-size-limit/13846146#13846146
    THREAD_SYNC_KEY = "LinuxAdmin-exitstatus"

    def launch(cmd, spawn_options = {})
      out_r, out_w = IO.pipe
      err_r, err_w = IO.pipe
      pid = Kernel.spawn(cmd, {:err => err_w, :out => out_w}.merge(spawn_options))
      wait_for_process(pid, out_w, err_w)
      wait_for_pipes(out_r, err_r)
    end

    def wait_for_process(pid, out_w, err_w)
      self.exitstatus = :not_done
      Thread.new(Thread.current) do |parent_thread|
        _, status = Process.wait2(pid)
        out_w.close
        err_w.close
        parent_thread[THREAD_SYNC_KEY] = status.exitstatus
      end
    end

    def wait_for_pipes(out_r, err_r)
      out = out_r.read
      err = err_r.read
      sleep(0.1) while exitstatus == :not_done
      return out, err
    end

    def exitstatus
      Thread.current[THREAD_SYNC_KEY]
    end

    def exitstatus=(value)
      Thread.current[THREAD_SYNC_KEY] = value
    end
  end
end
