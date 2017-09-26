require 'shellwords'
require 'net/ssh'
require 'parallel'
require 'colorize'

module Pec2
  class Pssh

    def initialize(options, servers, parallel = 1)
      @parallel = parallel
      color_index = 0
      colors = String.colors.select{ |color| !color.to_s.start_with?('light_') }
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
    end

    def exec_pssh_command(command)
      return false if command.nil? || command.empty?
      Parallel.each(@servers, in_threads: @parallel) do |server|
        Net::SSH.start(server[:host], @user) do |ssh|
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
      end
      return true
    end
  end
end
