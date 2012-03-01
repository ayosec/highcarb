
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

      create_file path.join("slides/0001.haml"),
        ".slide\n" +
        "  %h1 Title\n" +
        "  Content\n"

      create_file path.join("assets/README"),
        "Put in this directory any file that you want to use in your presentation (images, et al)\n\n" +
        "Files ending with .coffee will be compiled with CoffeeScript.\n" +
        "Files ending with .scss will be compiled with SASS. Compass is available."

      create_file path.join("assets/base.scss"),
        "/*\n * Write here your own styles.\n" +
        " * Compass modules are available\n */\n\n\n" +
        "@import url('/assets/vendor/deck.js/themes/style/swiss.css');\n" +
        "@import url('/assets/vendor/deck.js/themes/transition/horizontal-slide.css');\n"

      create_file path.join("assets/remote.scss"), "/* Add here your styles for the /remote view */"
      create_file path.join("assets/custom-remote.coffee"), "# Add here your own code for the /remote view"
      create_file path.join("assets/custom.coffee"), "# Add here your own code for the views"

      create_file path.join("snippets/README"),
        "Put in this directory any snippet of code that you want to include in your presentation.\n" +
        "You need to install Pygmentize if you want to format the code.\n" +
        "The snippets are loaded with a <snippet>name.rb</snippet> tag.\n" +
        "With Haml, you can use %snippet name.rb\n"

      # Download deck.js, which will include jQuery
      if not command.options["skip-libs"]
        vendor_path = path.join("assets/vendor")
        vendor_path.mkpath
        Dir.chdir vendor_path do
          puts "Downloading Deck.js into \033[1m#{vendor_path}\033[m..."
          system "curl -L https://github.com/imakewebthings/deck.js/tarball/master | tar xzf -"
          vendor_path.children.first.rename vendor_path.join("deck.js")
        end
      end
    end

    # Helpers

    def create_file(path, content)
      puts "Create \033[1m#{path}\033[m"
      path.dirname.mkpath
      path.open "w" do |f| f.write content end
    end
  end
end
