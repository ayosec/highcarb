
class WSConnection

  class <<self
    attr_accessor :connected_clients
  end

  self.connected_clients = []

  attr_reader :websocket

  def initialize(websocket)
    @websocket = websocket
    websocket.onopen &method(:on_open)
    websocket.onclose &method(:on_close)
    websocket.onmessage &method(:on_msg)
  end

  def on_open
    self.class.connected_clients << self
  end

  def on_close
    self.class.connected_clients.delete self
  end

  def on_msg(msg)
    self.class.connected_clients.each do |client|
      if client != self
        client.websocket.send msg
      end
    end
  end
end
