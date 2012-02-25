
require "sass"

module HighCarb
  module AssetsController
    def assets(asset)
      if asset.include?("/../")
        plain_response! 403, "URL can not contain /../"
      end

      asset_path = assets_root.join("./" + asset)
      if not asset_path.exist?
        not_found! asset
      end

      if not asset_path.file?
        plain_response! 403, "#{asset} is not a file"
      end

      output = nil
      mime_type = nil

      # Process SASS
      if asset_path.extname == ".scss"
        output = Sass::Engine.for_file(asset_path.to_s, {}).render
        mime_type = "text/css"
      end

      if output == nil
        mime_type = MIME::Types.type_for(asset_path.to_s).first || "application/octet-stream"
        output = asset_path.read
      end

      [
        200,
        { "Content-Type" => mime_type.to_s },
        output
      ]
    end
  end
end
