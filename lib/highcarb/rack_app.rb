
require "mime/types"
require "pathname"
require "haml"
require "kramdown"
require "yaml"

require "highcarb/assets_controller"
require "highcarb/message_queue"
require "highcarb/vendor_controller"
require "highcarb/views_controller"

module HighCarb

  class RackApp

    include AssetsController
    include VendorController
    include ViewsController

    attr_reader :assets_root
    attr_reader :command
    attr_reader :config
    attr_reader :logger
    attr_reader :root

    def initialize(command, logger)
      @command = command
      @logger = logger

      @root = Pathname.new(command.args.first)
      @assets_root = @root.join("./assets")

      config_path = @root.join("config.yaml")
      @config = config_path.exist? ? YAML.load(config_path.read) : {}

      if haml_filters = @config["haml_filters"]
        HighCarb::HamlFilters.register_all(@root, logger, haml_filters)
      end

      @msg_queue = HighCarb::MessageQueue.new(logger)
    end

    def plain_response!(status, content)
      throw :response, [status, {'Content-Type' => 'text/plain'}, content]
    end

    def not_found!(path)
      plain_response! 404, "Object #{path} not found"
    end

    def call(env)
      logger.info "#{env["REQUEST_METHOD"]} #{env["PATH_INFO"]}"

      catch(:response) do
        case env["PATH_INFO"]
        when /\A\/assets\/(.*)\Z/
          assets $1

        when /\A\/vendor\/(.*)\Z/
          vendor $1

        when "/socket"
          ws = Faye::WebSocket.new(env)
          @msg_queue.add(ws)
          ws.rack_response

        when "/"
          render_view "index"

        else
          not_found! env["PATH_INFO"]
        end
      end
    end

  end
end
