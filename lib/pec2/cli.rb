require "thor"
require "tempfile"
require "logger"
require 'shellwords'

module Pec2
  class CLI < Thor

    map '-v' => :version
    default_task :search_tag

    def initialize(args = [], options = {}, config = {})
      super(args, options, config)
      @global_options = config[:shell].base.options
      @core = Core.new
      @pssh_path = File.expand_path('../../../exe/bin/pssh', __FILE__)
      @logger = Logger.new(STDOUT)
    end

    desc 'search_tag', 'search tag'
    option :command, aliases: '-c', type: :string, required: true, desc: 'command'
    option :sudo_password, aliases: '-s', type: :string, desc: 'sudo_password'
    option :tag, aliases: '-t', type: :hash, default: {}, desc: 'tag'
    option :user, aliases: '-u', type: :string, desc: 'user'
    option :log, aliases: '-o', type: :string, desc: 'log'
    option :parallel, aliases: '-p', type: :numeric, desc: 'parallel'
    option :print, aliases: '-P', type: :boolean, default: false, desc: 'print stdout.'
    def search_tag
      cmd = ""
      addresses = @core.instances_hash(options[:tag]).map do |instance|
        instance.private_ip_address
      end

      if addresses.empty?
        @logger.error(%Q{no host tag #{options[:tag]}.})
        raise
      end

      tf = Tempfile.open("pec2") { |fp|
        fp.puts(addresses.join("\n"))
        fp
      }

      cmd = "#{@pssh_path} -t 0 -x '-tt' -h #{tf.path} -O StrictHostKeyChecking=no"
      if options[:print]
        cmd = "#{cmd} -P"
      end

      if options[:user]
        cmd = "#{cmd} -l #{options[:user]}"
      end

      if options[:log]
        cmd = "#{cmd} -o #{options[:log]}"
      end

      if options[:parallel]
        cmd = "#{cmd} -p #{options[:parallel]}"
      end

      if options[:sudo_password]
        cmd = %Q{(echo #{options[:sudo_password]}) | #{cmd} -I #{Shellwords.escape(options[:command])}}
      else
        cmd = %Q{#{cmd} -i #{Shellwords.escape(options[:command])}}
      end

      system(cmd)
      tf.close
    end

    desc 'version', 'show version'
    def version
      puts VERSION
    end
  end
end
