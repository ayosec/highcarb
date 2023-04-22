
require "pathname"

module HighCarb
  class Generator

    class PathAlreadyExist < HighCarb::Error
      def message
        "The path exist and can not overridden"
      end
    end

    attr_reader :path
    attr_reader :command

    def initialize(command, path)
      @command = command
      @path = path
    end

    def run!
      path = Pathname.new(self.path)
      raise PathAlreadyExist if path.exist?

      create_file path.join("slides/0001.haml"), <<~HAML
        .slide
          %h1 First

          Content

        .slide
          %h1 Second

          Content
      HAML

      create_file path.join("assets/README"), <<~TXT
        Put in this directory any file that you want to use in your presentation (images, et al)

        Files ending with .scss will be compiled with SASS. Compass is available.
      TXT

      create_file path.join("assets/main.scss"), <<~CSS
        /* Write here your own styles. */

        @import url("/vendor/slides.css");
      CSS

      create_file path.join("assets/remote.scss"), "/* Add here your styles for the /remote view. */\n"
      create_file path.join("assets/custom.js"), "// Add here your own code for the views.\n"

      create_file path.join("snippets/README"), <<~TXT
        Put in this directory any snippet of code that you want to include in
        your presentation.

        The snippets are loaded with a <snippet>name.rb</snippet> tag.
        With Haml, you can use %snippet name.rb
      TXT

      create_file path.join("config.yaml"), <<~YAML
        # Custom Haml filters.
        #
        # You can register your own filters for use on the slide sources. Each filter
        # is associated with a program that will be executed for each node using the
        # filter.
        #
        # The content of the filter is sent to the standard input of the program. Its
        # output will be added to the generated HTML.
        haml_filters:
      YAML
    end

    private def create_file(path, content)
      puts "Create \033[1m#{path}\033[m"
      path.dirname.mkpath
      path.open "w" do |f| f.write content end
    end

  end
end
