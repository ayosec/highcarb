
require "pathname"

module HighCarb
  class Generator

    class PathAlreadyExist < HighCarb::Error
      def message
        "The path exist and can not overridden"
      end
    end

    attr_reader :path

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
    end

    # Helpers

    def create_file(path, content)
      puts "Create \033[1m#{path}\033[m"
      path.dirname.mkpath
      path.open "w" do |f| f.write content end
    end
  end
end
