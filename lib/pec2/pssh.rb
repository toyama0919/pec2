require 'net/ssh'
require 'parallel'
require 'colorize'

module Pec2
  class Pssh

    def initialize(options, servers, parallel = 1)
      @parallel = parallel
      color_index = 0
      colors = String.colors.select{ |color|
        !color.to_s.start_with?('light_') && !color.to_s.include?('red') && !color.to_s.include?('yellow')
      }
      @servers = servers.map { |server|
        result = {}
        result[:host] = server
        result[:color] = colors[color_index]
        if colors.size == color_index + 1
          color_index = 0
        else
          color_index = color_index + 1
        end
        result
      }
      @user = options[:user]
      @print = options[:print]
      @sudo_password = options[:sudo_password]
      @ssh_options = {
        verify_host_key: false,
        user_known_hosts_file: '/dev/null',
      }
      @logger = Logger.new(STDOUT)
    end

    def exec_pssh_command(command)
      return false if command.nil? || command.empty?
      exit_status = {}
      Parallel.map(@servers, in_threads: @parallel) do |server|
        exit_status[server[:host]] = exec_ssh(server, command)
      end
      errors = exit_status.select {|k, v| v != 0 }
      if errors.size > 0
        @logger.error "error servers => #{errors.keys.join(', ')}".colorize(:red)
        return false
      end
      return true
    end

    private

    def exec_ssh(server, command)
      exit_code = nil
      begin
        Net::SSH.start(server[:host], @user, @ssh_options) do |ssh|
          channel = ssh.open_channel do |channel, success|
            channel.on_data do |channel, data|
              if data =~ /^\[sudo\] password for /
                channel.send_data "#{@sudo_password}\n"
              else
                data.to_s.lines.each do |line|
                  if @print
                    print %Q{#{server[:host]}:#{line}}.colorize(server[:color])
                  end
                end
              end
            end
            channel.request_pty
            channel.exec(command) do |ch, success|
              channel.on_request("exit-status") do |ch,data|
                exit_code = data.read_long
              end
            end
            channel.wait
          end
          channel.wait
        end
      rescue => e
        puts "\n#{e.message}\n#{e.backtrace.join("\n")}"
      end
      return exit_code
    end
  end
end
