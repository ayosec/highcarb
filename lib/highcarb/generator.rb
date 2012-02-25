
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
        "    Content\n"

      create_file path.join("assets/README"),
        "Put in this directory any file that you want to use in your presentation (images, et al)\n"

      create_file path.join("styles/base.scss"),
        "/*\n * This file will be included in the generated HTML after been processed with the SASS compiler.\n" +
        " * You can use the Compass modules if you want\n */\n"

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
