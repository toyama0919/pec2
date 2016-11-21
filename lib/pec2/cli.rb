require "thor"
require "tempfile"

module Pec2
  class CLI < Thor

    map '-v' => :version
    default_task :search_tag

    def initialize(args = [], options = {}, config = {})
      super(args, options, config)
      @global_options = config[:shell].base.options
      @core = Core.new
      @pssh_path = `which pssh`.strip
    end

    desc 'search_tag', 'search tag'
    option :command, aliases: '-c', type: :string, required: true, desc: 'command'
    option :sudo_password, aliases: '-s', type: :string, desc: 'sudo_password'
    option :tag, aliases: '-t', type: :hash, default: {}, desc: 'tag'
    option :user, aliases: '-u', type: :string, desc: 'user'
    option :log, aliases: '-o', type: :string, desc: 'log'
    option :print, aliases: '-P', type: :boolean, default: false, desc: 'print stdout.'
    def search_tag
      Tempfile.create("pec2") do |f|
        addresses = @core.instances_hash(options[:tag]).map do |instance|
          instance.private_ip_address
        end

        if addresses.empty?
          raise "no host."
        end

        File.write(f.path, addresses.join("\n"))
        cmd = "#{@pssh_path} -t 0 -x '-tt' -h #{f.path} -O StrictHostKeyChecking=no"

        if options[:print]
          cmd = "#{cmd} -P"
        end

        if options[:user]
          cmd = "#{cmd} -l #{options[:user]}"
        end

        if options[:log]
          cmd = "#{cmd} -o #{options[:log]}"
        end

        if options[:sudo_password]
          cmd = %Q{(echo #{options[:sudo_password]}) | #{cmd} -I '#{options[:command]}'}
        else
          cmd = %Q{#{cmd} -i '#{options[:command]}'}
        end
        system(cmd)
      end
    end

    desc 'version', 'show version'
    def version
      puts VERSION
    end
  end
end
