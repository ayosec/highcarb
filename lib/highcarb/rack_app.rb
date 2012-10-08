
require "mime/types"
require "pathname"
require "haml"
require "kramdown"
require "yaml"

require "highcarb/assets_controller"
require "highcarb/slides_controller"
require "highcarb/views_controller"

module HighCarb

  class RackApp

    include SlidesController
    include AssetsController
    include ViewsController

    attr_reader :command
    attr_reader :root
    attr_reader :assets_root
    attr_reader :config

    def initialize(command)
      @command = command
      @root = Pathname.new(command.args.first)
      @assets_root = @root.join("./assets")

      config_path = @root.join("config.yml")
      @config = config_path.exist? ? YAML.load(config_path.read) : {}
    end

    def plain_response!(status, content)
      throw :response, [status, {'Content-Type' => 'text/plain'}, content]
    end

    def not_found!(path)
      plain_response! 404, "Object #{path} not found"
    end

    def call(env)
      catch(:response) do
        case env["PATH_INFO"]
        when "/slides"
          slides

        when /\A\/assets\/(.*)\Z/
          assets $1

        when "/remote"
          render_view "remote"

        when "/"
          render_view "index"

        else
          not_found! env["PATH_INFO"]
        end
      end
    end

  end
end
