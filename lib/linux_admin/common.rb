require 'shellwords'

class LinuxAdmin
  class CommandError < RuntimeError; end

  module Common
    def write(file, content)
      raise ArgumentError, "file and content can not be empty" if file.blank? || content.blank?
      File.open(file, "w") do |f|
        f.write(content)
      end
    end

    def cmd(cmd)
      Distro.local.class::COMMANDS[cmd]
    end

    def run(cmd, options = {})
      params = options[:params] || options[:parameters]

      begin
        launch_params = {}
        launch_params[:chdir] = options[:chdir] if options[:chdir]
        out = launch(build_cmd(cmd, params), launch_params)

        if options[:return_output] && exitstatus == 0
          out
        elsif options[:return_exitstatus] || exitstatus == 0
          exitstatus
        else
          raise CommandError, "#{build_cmd(cmd, params)}: exit code: #{exitstatus}"
        end
      rescue
        return nil if options[:return_exitstatus]
        raise
      ensure
        self.exitstatus = nil
      end
    end

    private

    def sanitize(params)
      return [] if params.blank?
      params.collect do |k, v|
        v = case v
            when Array;    v.collect(&:shellescape)
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
      pipe_r, pipe_w = IO.pipe
      pid = Kernel.spawn(cmd, {:err => [:child, :out], :out => pipe_w}.merge(spawn_options))
      wait_for_process(pid, pipe_w)
      wait_for_output(pipe_r)
    end

    def wait_for_process(pid, pipe_w)
      self.exitstatus = :not_done
      Thread.new(Thread.current) do |parent_thread|
        _, status = Process.wait2(pid)
        pipe_w.close
        parent_thread[THREAD_SYNC_KEY] = status.exitstatus
      end
    end

    def wait_for_output(pipe_r)
      out = pipe_r.read
      sleep(0.1) while exitstatus == :not_done
      return out
    end

    def exitstatus
      Thread.current[THREAD_SYNC_KEY]
    end

    def exitstatus=(value)
      Thread.current[THREAD_SYNC_KEY] = value
    end
  end
end
