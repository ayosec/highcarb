
window.WebSocket = MozWebSocket if MozWebSocket?

$ ->

  # Load slides and initialize Deck.js
  $.get "/slides",
    (data) ->
      $(".slides").replaceWith data
      $(".slides").find(".note").remove()
      $.deck ".slide"

  # Open a permanent connection to the server. With this channel
  # we can receive commands to change the current slide
  toJson = JSON.stringify


  # Don't initialize the websocket if we don't have any URL
  return unless EnableWebSocketsURL


  channel = new WebSocket WebSocketsURL
  channel.onmessage = (msgEvent) ->
    msg = JSON.parse(msgEvent.data)

    switch msg.action
      when "next-slide" then $.deck('next')
      when "prev-slide" then $.deck('prev')
      when "go-to"
        for slide, index in $.deck('getSlides')
          if slide.data("slide-id") == msg.slideId
            $.deck("go", index)
            break

  channel.onopen = ->
    channel.send toJson(ack: true)

  # Send a notification to every other client when the current slide has changed
  lastSlideSelectedEvent = -1
  $(document).bind 'deck.change', (event, from, to) ->
    if lastSlideSelectedEvent != -1
      clearTimeout lastSlideSelectedEvent

    lastSlideSelectedEvent = \
      setTimeout ->
        lastSlideSelectedEvent = -1
        channel.send toJson(action: "slide-selected", slideId: $.deck('getSlide').data("slide-id"))
      100
