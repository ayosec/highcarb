
require "thin"
require "highcarb/rack_app"

module HighCarb
  module Services
    extend self

    def start!(command, logger, auth)
      Thin::Server.start(
        '0.0.0.0',
        command.options["http-port"],
        Rack::Builder.new do
          if auth
            use Rack::Auth::Basic, "HighCarb" do |username, password|
              username == auth[0] && password == auth[1]
            end
          end

          run RackApp.new(command, logger)
        end
      )
    end

  end
end
