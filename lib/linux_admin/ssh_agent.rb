require 'fileutils'
module LinuxAdmin
  class SSHAgent
    attr_accessor :pid
    attr_reader :socket

    def initialize(ssh_private_key, agent_socket = nil)
      @socket = agent_socket
      @private_key = ssh_private_key
    end

    def start
      if @socket
        FileUtils.mkdir_p(File.dirname(@socket))
        agent_details = `ssh-agent -a #{@socket}`
      else
        agent_details = `ssh-agent`
        @socket = parse_ssh_agent_socket(agent_details)
      end
      @pid = parse_ssh_agent_pid(agent_details)
      IO.popen({'SSH_AUTH_SOCK' => @socket, 'SSH_AGENT_PID' => @pid}, ['ssh-add', '-'], :mode => 'w') do |f|
        f.puts(@private_key)
      end
      raise StandardError, "Couldn't add key to agent" if $CHILD_STATUS.to_i != 0
    end

    def with_service
      start
      yield @socket
    ensure
      stop
    end

    def stop
      system({'SSH_AGENT_PID' => @pid}, '(ssh-agent -k) &> /dev/null') if process_exists?(@pid)
      File.delete(@socket) if File.exist?(@socket)
      @socket = nil
      @pid = nil
    end

    private

    def process_exists?(process_pid)
      Process.kill(0, process_pid) == 1
    rescue
      false
    end

    def parse_ssh_agent_socket(output)
      parse_ssh_agent_output(output, 1)
    end

    def parse_ssh_agent_pid(output)
      parse_ssh_agent_output(output, 2)
    end

    def parse_ssh_agent_output(output, index)
      output.split('=')[index].split(' ')[0].chop
    end
  end
end
