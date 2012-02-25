
require "mime/types"
require "pathname"

module HighCarb

  class RackApp

    attr_reader :command
    attr_reader :assets_root

    def initialize(command)
      @command = command
      @assets_root = Pathname.new(command.args.first + "/assets")
    end

    def call(env)
      catch(:response) do
        case env["PATH_INFO"]
        when "/slides"
          slides

        when /\A\/assets\/(.*)\Z/
          assets $1

        when "/remote"
          remote

        when "/"
          root

        else
          not_found! env["PATH_INFO"]
        end
      end
    end

    def plain_response!(status, content)
      throw :response, [status, {'Content-Type' => 'text/plain'}, content]
    end

    def not_found!(path)
      plain_response! 404, "Object #{path} not found"
    end

    def assets(asset)
      if asset.include?("/../")
        plain_response! 403, "URL can not contain /../"
      end

      asset_path = assets_root.join(asset)
      if not asset_path.exist?
        not_found! asset
      end

      if not asset_path.file?
        plain_response! 403, "#{asset} is not a file"
      end

      mime_type = MIME::Types.type_for(asset_path.to_s).first || "application/octet-stream"

      [
        200,
        { "Content-Type" => mime_type.to_s },
        asset_path.read
      ]
    end
  end
end
