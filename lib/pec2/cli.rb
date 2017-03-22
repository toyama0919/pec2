require "thor"
require "tempfile"
require "logger"

module Pec2
  class CLI < Thor

    map '-v' => :version
    default_task :run_command

    def initialize(args = [], options = {}, config = {})
      super(args, options, config)
      @global_options = config[:shell].base.options
      @core = Ec2.new
      @logger = Logger.new(STDOUT)
    end

    desc 'run_command', 'run command'
    option :command, aliases: '-c', type: :string, desc: 'command'
    option :sudo_password, aliases: '-s', type: :string, desc: 'sudo_password'
    option :tag, aliases: '-t', type: :hash, default: {}, desc: 'tag'
    option :user, aliases: '-u', type: :string, desc: 'user'
    option :log, aliases: '-o', type: :string, desc: 'log'
    option :parallel, aliases: '-p', type: :numeric, desc: 'parallel'
    option :print, aliases: '-P', type: :boolean, default: false, desc: 'print stdout.'
    option :resolve, aliases: '--resolve', type: :string, default: 'private_ip_address', enum: ['private_ip_address', 'public_ip_address', 'name_tag'], desc: 'resolve'
    def run_command
      addresses = @core.instances_hash(options[:tag]).map do |instance|
        if options[:resolve] == 'private_ip_address'
          instance.private_ip_address
        elsif options[:resolve] == 'public_ip_address'
          instance.public_ip_address
        elsif options[:resolve] == 'name_tag'
          instance.tags.select{|tag| tag["key"] == "Name" }.first["value"]
        end
      end

      if addresses.empty?
        @logger.info(%Q{no host tag #{options[:tag]}.})
        exit
      end

      @logger.info(%Q{connection size #{addresses.size}.})
      @logger.info(%Q{listing connection to #{addresses.join(', ')}.})

      tf = Tempfile.open("pec2") { |fp|
        fp.puts(addresses.join("\n"))
        fp
      }

      pssh = Pssh.new(options, tf.path, addresses.size)

      interactive = options[:command] ? false : true

      if interactive
        while true
          command = ask(">:")
          pssh.exec_pssh_command(command)
        end
      else
        ret = pssh.exec_pssh_command(options[:command])
        unless ret
          tf.close
          exit 1
        end
      end
      tf.close
    end

    desc 'version', 'show version'
    def version
      puts VERSION
    end
  end
end
