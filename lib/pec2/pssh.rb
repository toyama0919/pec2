require 'shellwords'

module Pec2
  class Pssh

    PSSH_PATH = File.expand_path('../../../exe/bin/pssh', __FILE__)

    def initialize(options, hosts_file, parallel = 1)
      @pssh_command = "#{PSSH_PATH} -t 0 -x '-tt' -h #{hosts_file} -O StrictHostKeyChecking=no"
      if options[:print]
        @pssh_command = "#{@pssh_command} -P"
      end

      if options[:user]
        @pssh_command = "#{@pssh_command} -l #{options[:user]}"
      end

      if options[:log]
        @pssh_command = "#{@pssh_command} -o #{options[:log]}"
      end

      @pssh_command = "#{@pssh_command} -p #{options[:parallel] || parallel}"
      @sudo_password = options[:sudo_password]
    end

    def build_pssh_command(command)
      if @sudo_password
        %Q{(echo #{@sudo_password}) | #{@pssh_command} -I #{Shellwords.escape(command)}}
      else
        %Q{#{@pssh_command} -i #{Shellwords.escape(command)}}
      end
    end

    def exec_pssh_command(command)
      return false if command.nil? || command.empty?
      build_command = build_pssh_command(command)
      system(build_command)
    end
  end
end