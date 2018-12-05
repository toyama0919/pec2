require 'open-uri'

module Pec2
  class Metadata
    class << self
      def get_document
        JSON.parse(get_metadata('/latest/dynamic/instance-identity/document/'))
      end

      def get_metadata(path)
        begin
          result = {}
          ::Timeout.timeout(TIME_OUT) {
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
end
