
require "mime/types"
require "pathname"
require "haml"
require "kramdown"

module HighCarb

  class RackApp

    attr_reader :command
    attr_reader :root
    attr_reader :assets_root

    def initialize(command)
      @command = command
      @root = Pathname.new(command.args.first)
      @assets_root = @root.join("/assets")
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


    def slides
      output = []

      root.join("slides").children.sort.each do |slide_file|
        # Only use non-hidden files
        if slide_file.file? and slide_file.to_s !~ /^\./
          case slide_file.extname.downcase
          when ".haml"
            output << Haml::Engine.new(slide_file.read).render

          when ".html"
            output << slide_file.read

          when ".md"
            output << Kramdown::Document.new(slide_file.read).to_html

          else
            STDERR.puts "\033[31mCan not parse #{slide_file}\033[m"
          end
        end
      end

      throw :response, [200, {'Content-Type' => 'text/html'}, output]

    end
  end
end
