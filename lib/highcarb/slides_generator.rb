
require "nokogiri"

module HighCarb
  module SlidesGenerator
    def slides
      output = []

      # Load the content from the sources
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

      page = Nokogiri::HTML.parse(output.join)

      # Find the <snippet> tags and replace with the content from a
      # file located under the snippet/ directory
      page.search("snippet").each do |snippet_tag|
        snippet_tag.replace load_snippet(snippet_tag.inner_text.strip)
      end

      # Response with everything
      output = page.at("body").inner_html
      throw :response, [200, {'Content-Type' => 'text/html'}, output]
    end

    def load_snippet(snippet_name)
      snippet_path = root.join("snippets", snippet_name)
      begin
        IO.popen(["pygmentize", "-f", "html", "-O", "noclasses=true", snippet_path.to_s]).read
      rescue Errno::ENOENT
        if not @pygmentize_error_shown
          STDERR.puts "\033[31mpygmentize could not be used. You have to install it if you want to highlight the snippets."
          STDERR.puts "The snippets will be included with no format\033[m"
          @pygmentize_error_shown = true
        end

        %[<pre class="raw-snippet">#{ERB::Util.h snippet_path.read}</pre>]
      end
    end
  end
end
