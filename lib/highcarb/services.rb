
require "thin"
require "em-websocket"

require "highcarb/rack_app"
require "highcarb/sockets"

module HighCarb
  module Services
    extend self

    def start!(command, logger)
      EM.run do
        EM::WebSocket.start(host: '0.0.0.0', port: command.options["ws-port"] ) do |websocket|
          WSConnection.new websocket, logger
        end

        Thin::Server.start(
          '0.0.0.0',
          command.options["http-port"],
          Rack::Builder.new { run RackApp.new(command) }
        )
      end
    end

  end
end
