require 'aws-sdk'
require 'hashie/mash'
require 'logger'
require 'open-uri'
require 'json'
require 'timeout'

class Pec2Mash < ::Hashie::Mash
  disable_warnings
end

module Pec2
  class Core

    def initialize
      @logger = Logger.new(STDOUT)
      ENV['AWS_REGION'] = ENV['AWS_REGION'] || get_document['region']
      @ec2 = Aws::EC2::Client.new
    end

    def instances_hash(condition)
      filter = []
      condition.each do |key, value|
        filter << { name: "tag:#{key}", values: ["#{value}"] }
      end
      filter << { name: 'instance-state-name', values: ['running'] }
      @ec2.describe_instances(
        filters: filter
      ).data.to_h[:reservations].map { |instance| Pec2Mash.new(instance[:instances].first) }
    end

    def get_document
      JSON.parse(get_metadata('/latest/dynamic/instance-identity/document/'))
    end

    def get_metadata(path)
      begin
        result = {}
        Timeout.timeout(TIME_OUT) {
          body = open('http://169.254.169.254' + path).read
          return body
        }
        return result
      rescue Timeout::Error => e
        raise "not EC2 instance"
      end
    end
  end
end
