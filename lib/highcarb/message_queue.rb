require "faye/websocket"

Faye::WebSocket.load_adapter('thin')

module HighCarb
  class MessageQueue

    attr_reader :connected_clients
    attr_reader :last_client_id
    attr_reader :logger

    def initialize(logger)
      @logger = logger
      @connected_clients = {}
      @last_client_id = 0
    end

    def add(websocket)
      @last_client_id += 1

      client_id = @last_client_id

      websocket.on :open do
        logger.info "[WS] Connected client: #{client_id}"
        @connected_clients[client_id] = websocket
      end

      websocket.on :close do |event|
        logger.info "[WS] Closed client: #{client_id} (#{event.code}, #{event.reason})"
        @connected_clients.delete(client_id)
      end

      websocket.on :message do |event|
        logger.info "[WS] Message from #{client_id}: #{event.data.inspect}"

        @connected_clients.each_pair do |id, remote_socket|
          if id != client_id
            remote_socket.send(event.data)
          end
        end
      end
    end
  end
end
