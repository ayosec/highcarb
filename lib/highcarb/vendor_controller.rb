require "sassc"

module HighCarb
  module VendorController
    VENDOR_ROOT = Pathname.new(File.expand_path("../../../resources", __FILE__))

    def vendor(name)

      case name
      when "slides.css"
        mime_type = "text/css"

        source = VENDOR_ROOT.join("styles/slides.scss")
        output = SassC::Engine.new(source.read, filename: source.to_s).render

      when "shower.js", "remote-sync.js"
        mime_type = "application/javascript"
        output = VENDOR_ROOT.join("javascript/#{name}").read

      else
        plain_response! 404, "Not Found"
      end

      [
        200,
        { "Content-Type" => mime_type },
        output
      ]
    end
  end
end
