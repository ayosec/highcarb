
require "sinatra"

module HighCarb
  class SinatraApp < Sinatra::Base

    get "/" do
      # WebSocket POC
      %[
        <script>
          setTimeout(function() {
            var ws = new WebSocket("ws://localhost:#{Options["ws-port"]}");
            ws.onmessage = function(msg) {
              var newDiv = document.createElement("DIV");
              newDiv.appendChild(document.createTextNode(msg));
              document.body.appendChild(newDiv);
            }

            ws.onopen = function() {
              ws.send("hi!");
            }
          }, 100);
        </script>
      ]
    end

  end
end
