
module HighCarb
  class WSConnection

    class <<self
      attr_accessor :connected_clients
      attr_accessor :last_client_id
    end

    self.connected_clients = []
    self.last_client_id = 0

    attr_reader :client_id
    attr_reader :websocket
    attr_reader :logger

    def initialize(websocket, logger)
      @logger = logger
      @client_id = (self.class.last_client_id += 1)

      @websocket = websocket
      websocket.onopen &method(:on_open)
      websocket.onclose &method(:on_close)
      websocket.onmessage &method(:on_msg)
    end

    def on_open
      logger.info { "[WS] Open client: #{client_id}" }
      self.class.connected_clients << self
    end

    def on_close
      logger.info { "[WS] Closed client: #{client_id}" }
      self.class.connected_clients.delete self
    end

    def on_msg(msg)
      logger.info { "[WS] Message from #{client_id}: #{msg}" }

      self.class.connected_clients.each do |client|
        if client != self
          client.websocket.send msg
        end
      end
    end
  end
end
