
require "json"
require "coffee-script"

module HighCarb
  module ViewsController

    DefaultViewsPath = Pathname.new(File.expand_path("../../../resources/views/", __FILE__))

    class ViewContext
      attr_reader :options, :root
      def initialize(options, root)
        @options = options
        @root = root
      end

      def load_coffe(source)
        "<script>//<![CDATA[\n" + CoffeeScript.compile(root.join(source + ".coffee").read) + "\n//]]></script>"
      end
    end

    def render_view(view_name)
      view_path = root.join("views", view_name + ".haml")
      if not view_path.exist?
        view_path = DefaultViewsPath.join(view_name + ".haml")
      end

      if not view_path.exist?
        not_found!
      end

      output = Haml::Engine.new(view_path.read).render(ViewContext.new(command.options, view_path.dirname))

      throw :response, [200, {'Content-Type' => 'text/html'}, output]
    end

  end
end
