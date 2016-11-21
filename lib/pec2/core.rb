require 'aws-sdk'
require 'hashie'
require 'logger'

module Pec2
  class Core

    def initialize
      @logger = Logger.new(STDOUT)
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
      ).data.to_h[:reservations].map { |instance| Hashie::Mash.new(instance[:instances].first) }
    end
  end
end
