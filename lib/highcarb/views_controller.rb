require "json"

module HighCarb
  module ViewsController

    DefaultViewsPath = Pathname.new(File.expand_path("../../../resources/views/", __FILE__))

    class ViewContext
      attr_reader :app, :options, :root
      def initialize(app, options, root)
        @app = app
        @options = options
        @root = root
      end

      def jquery_path
        Dir.chdir(root) { Dir["assets/vendor/deck.js/jquery-*.js"].first }
      end
    end

    def render_view(view_name)
      view_path = root.join("views", view_name + ".haml")
      if not view_path.exist?
        view_path = DefaultViewsPath.join(view_name + ".haml")
      end

      if not view_path.exist?
        not_found! view_name + " view"
      end

      output = Haml::Template.new(view_path).render(ViewContext.new(self, command.options, view_path.dirname))

      throw :response, [200, {'Content-Type' => 'text/html'}, output]
    end

  end
end
