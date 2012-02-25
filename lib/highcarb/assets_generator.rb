
module SlidesGenerator
  module AssetsGenerator
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
