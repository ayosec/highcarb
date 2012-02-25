
$ ->
  $(".deck-container").load "/slides",
    -> $.deck ".slide"

  toJson = JSON.stringify

  socketConnection = new WebSocket WebSocketsURL
  socketConnection.onmessage = (msg) ->
    console.log msg

  socketConnection.onopen = ->
    socketConnection.send toJson(ack: true)
