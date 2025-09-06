# frozen_string_literal: true

module LLM
  ##
  # @api private
  module Client
    private

    ##
    # @api private
    def persistent_client
      mutex.synchronize do
        if clients[client_id]
          clients[client_id]
        else
          require "net/http/persistent" unless defined?(Net::HTTP::Persistent)
          client = Net::HTTP::Persistent.new(name: self.class.name)
          client.read_timeout = timeout
          clients[client_id] = client
        end
      end
    end

    ##
    # @api private
    def transient_client
      client = Net::HTTP.new(host, port)
      client.read_timeout = timeout
      client.use_ssl = ssl
      client
    end

    def client_id
      "#{host}:#{port}:#{timeout}:#{ssl}"
    end
  end
end
