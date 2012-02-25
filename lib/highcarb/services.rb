
require "thin"
require "em-websocket"

require "highcarb/sinatra"
require "highcarb/sockets"

module HighCarb
  module Services
    extend self

    def start!(command)
      EM.run do

        EM::WebSocket.start(host: '0.0.0.0', port: command.options["ws-port"] ) do |websocket|
          WSConnection.new websocket
        end

        SinatraApp.run! port: command.options["http-port"]
      end
    end

  end
end
