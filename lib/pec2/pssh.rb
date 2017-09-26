require 'shellwords'
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
      error_servers = []
      Parallel.each(@servers, in_threads: @parallel) do |server|
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
              channel.exec(command)
              channel.wait
            end
            channel.wait
          end
        rescue => e
          error_servers << server[:host]
          puts "\n#{e.message}\n#{e.backtrace.join("\n")}"
        end
      end
      if error_servers.size > 0
        @logger.error "error servers => #{error_servers.join(', ')}".colorize(:red)
      end
      return true
    end
  end
end
