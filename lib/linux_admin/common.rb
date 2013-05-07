module LinuxAdmin
  module Common
    def self.run(cmd, options = {})
      begin
        out = launch(cmd)
        if options[:return_output] && exitstatus == 0
          out
        elsif options[:return_exitstatus] || exitstatus == 0
          exitstatus
        else
          raise "Error: Exit Code #{exitstatus}"
        end
      rescue
        return nil if options[:return_exitstatus]
        raise
      ensure
        self.exitstatus = nil
      end
    end

    private

    # IO pipes have a maximum size of 64k before blocking,
    # so we need to read and write synchronously.
    # http://stackoverflow.com/questions/13829830/ruby-process-spawn-stdout-pipe-buffer-size-limit/13846146#13846146
    THREAD_SYNC_KEY = "LinuxAdmin-exitstatus"

    def self.launch(cmd)
      pipe_r, pipe_w = IO.pipe
      pid = Kernel.spawn(cmd, :err => [:child, :out], :out => pipe_w)
      wait_for_process(pid, pipe_w)
      wait_for_output(pipe_r)
    end

    def self.wait_for_process(pid, pipe_w)
      self.exitstatus = :not_done
      Thread.new(Thread.current) do |parent_thread|
        _, status = Process.wait2(pid)
        pipe_w.close
        parent_thread[THREAD_SYNC_KEY] = status.exitstatus
      end
    end

    def self.wait_for_output(pipe_r)
      out = pipe_r.read
      sleep(0.1) while exitstatus == :not_done
      return out
    end

    def self.exitstatus
      Thread.current[THREAD_SYNC_KEY]
    end

    def self.exitstatus=(value)
      Thread.current[THREAD_SYNC_KEY] = value
    end
  end
end