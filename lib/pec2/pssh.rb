require 'shellwords'
require 'net/ssh'
require 'parallel'

module Pec2
  class Pssh

    def initialize(options, servers, parallel = 1)
      @parallel = parallel
      @servers = servers
      @user = options[:user]
      @print = options[:print]
      @sudo_password = options[:sudo_password]
    end

    def exec_pssh_command(command)
      return false if command.nil? || command.empty?
      Parallel.each(@servers, in_threads: @parallel) do |server|
        Net::SSH.start(server, @user) do |ssh|
          channel = ssh.open_channel do |channel, success|
            channel.on_data do |channel, data|
              if data =~ /^\[sudo\] password for /
                channel.send_data "#{@sudo_password}\n"
              else
                data.to_s.lines.each do |line|
                  if @print
                    puts %Q{#{server}:#{line}}
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
    end
  end
end
