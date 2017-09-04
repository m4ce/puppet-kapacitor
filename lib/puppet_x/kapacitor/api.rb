require 'kapacitor/client' if Puppet.features.kapacitor_api?

module PuppetX
  module Kapacitor
    module API
      @@client = nil

      def api
        return @@client if @@client

        begin
          @@client = ::Kapacitor::Client.new(url: ENV['KAPACITOR_API_URL'] || "http://localhost:9092/kapacitor", version: ENV['KAPACITOR_API_VERSION'] || 'v1preview')
        rescue Exception => e
          fail "#{e.message} (#{e.error})"
        end

        @@client
      end
    end
  end
end
