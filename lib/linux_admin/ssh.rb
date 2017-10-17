module LinuxAdmin
  class SSH
    attr_reader :ip
    attr_reader :username
    attr_reader :private_key
    attr_reader :agent

    def initialize(ip, username, private_key = nil, password = nil)
      @ip = ip
      @private_key = private_key
      @username = username
      @password = password
    end

    def perform_commands(commands = [], agent_socket = nil, stdin = nil)
      require 'net/ssh'
      if block_given?
        execute_commands(commands, agent_socket, stdin, &Proc.new)
      else
        execute_commands(commands, agent_socket, stdin)
      end
    end

    private

    def execute_commands(commands, agent_socket, stdin)
      result = nil
      args = {:verify_host_key => false, :number_of_password_prompts => 0}
      if agent_socket
        args.merge!(:forward_agent              => true,
                    :agent_socket_factory       => -> { UNIXSocket.open(agent_socket) })
      elsif @private_key
        args[:key_data] = [@private_key]
      elsif @password
        args[:password] = @password
      end
      Net::SSH.start(@ip, @username, args) do |ssh|
        if block_given?
          result = yield ssh
        else
          commands.each do |cmd|
            result = ssh_exec!(ssh, cmd, stdin)
            result[:last_command] = cmd
            break if result[:exit_status] != 0
          end
        end
      end
      result
    end

    def ssh_exec!(ssh, command, stdin)
      stdout_data = ''
      stderr_data = ''
      exit_status = nil
      exit_signal = nil

      ssh.open_channel do |channel|
        channel.request_pty unless stdin
        channel.exec(command) do |_, success|
          channel.send_data(stdin) if stdin
          channel.eof!
          raise StandardError, "Command \"#{command}\" was unable to execute" unless success
          channel.on_data do |_, data|
            stdout_data << data
          end
          channel.on_extended_data do |_, _, data|
            stderr_data << data
          end
          channel.on_request('exit-status') do |_, data|
            exit_status = data.read_long
          end

          channel.on_request('exit-signal') do |_, data|
            exit_signal = data.read_long
          end
        end
      end
      ssh.loop
      {
        :stdout      => stdout_data,
        :stderr      => stderr_data,
        :exit_status => exit_status,
        :exit_signal => exit_signal
      }
    end
  end
end
