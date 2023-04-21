require "highcarb/slides_render"

module HighCarb
  module ViewsController

    DefaultViewsPath = Pathname.new(File.expand_path("../../../resources/views/", __FILE__))

    ViewContext = Struct.new(:app, :options, :root, :slides)

    def render_view(view_name)
      view_path = root.join("views", view_name + ".haml")
      if not view_path.exist?
        view_path = DefaultViewsPath.join(view_name + ".haml")
      end

      if not view_path.exist?
        not_found! view_name + " view"
      end

      slides = SlidesRender.new(root)

      ctx = ViewContext.new(self, command.options, view_path.dirname, slides.render)
      output = Haml::Template.new(view_path).render(ctx)

      throw :response, [200, {'Content-Type' => 'text/html'}, output]
    end

  end
end
