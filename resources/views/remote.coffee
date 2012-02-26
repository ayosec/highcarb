
window.WebSocket = MozWebSocket if MozWebSocket?

$ ->
  $(".slides").
    load("/slides").
    delegate(".slide", "click", (event) ->
      node = event.target
      while node
        slideId = $(node).data("slide-id")
        if slideId
          event.preventDefault()
          channel.send toJson(action: "go-to", slideId: slideId)
          return false

        node = node.parentNode

      true
    )

  toJson = JSON.stringify

  channel = new WebSocket WebSocketsURL
  channel.onmessage = (msgEvent) ->
    msg = JSON.parse(msgEvent.data)

    # Set the remote-selected class to the new slide
    $(".remote-selected").removeClass "remote-selected"
    item = $(".slide[data-slide-id=#{msg.slideId}]").
      addClass("remote-selected")

    # Keep the selected item always in the center
    offset = item.offset()
    if offset
      newTop = offset.top - ($(window).height() - item.height()) / 2
      #$("html").scrollTop newTop
      $("html").animate(scrollTop: newTop, 300)

  channel.onopen = ->
    channel.send toJson(ack: true)

  # Send commands to the presenter
  nextSlide = -> channel.send toJson(action: "next-slide")
  prevSlide = -> channel.send toJson(action: "prev-slide")
  $(".actions .next").click nextSlide
  $(".actions .prev").click prevSlide

  $(document).keypress (event) ->
    switch(event.keyCode)
      when 37 then prevSlide()
      when 39 then nextSlide()
      else return

    event.preventDefault()


