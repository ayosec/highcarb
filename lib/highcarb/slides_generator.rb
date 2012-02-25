
module HighCarb
  module SlidesGenerator

    def slides
      output = []

      root.join("slides").children.sort.each do |slide_file|
        # Only use non-hidden files
        if slide_file.file? and slide_file.to_s !~ /^\./
          case slide_file.extname.downcase
          when ".haml"
            output << Haml::Engine.new(slide_file.read).render

          when ".html"
            output << slide_file.read

          when ".md"
            output << Kramdown::Document.new(slide_file.read).to_html

          else
            STDERR.puts "\033[31mCan not parse #{slide_file}\033[m"
          end
        end
      end

      throw :response, [200, {'Content-Type' => 'text/html'}, output]

    end
  end
end
