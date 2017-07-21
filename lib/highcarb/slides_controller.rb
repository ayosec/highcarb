require "digest/md5"
require "nokogiri"
require "rouge"

module HighCarb
  module SlidesController
    def slides
      output = []

      # Load the content from the sources
      root.join("slides").children.sort.each do |slide_file|
        # Only use non-hidden files
        if slide_file.file? and slide_file.basename.to_s !~ /^\./
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

      # Find the <asset> tags and replace with link, script or img,
      # depending on the MIME type
      page.search("asset").each do |asset_tag|
        asset_tag.replace load_asset(asset_tag.inner_text.strip, asset_tag.attributes["class"].to_s.split)
      end

      # Find the <external> tags and replace with <a>
      # The text shown will be reduced
      page.search("external").each do |external_tag|
        href = ERB::Util.h(external_tag.inner_text.strip)

        text = href.gsub(/\w+:\/+/, "")
        text = text[0,45] + "&hellip;" if text.length > 45

        external_tag.replace %[<a class="external" href="#{href}" target="_blank" title="Open #{href} in a new window">#{text}</a>]
      end

      # Append a server side generated identifier. This helps to identify them
      # both in presenter- and remote-control-mode
      last_slide_id = 0
      page.search(".slide").each do |slide_node|
        last_slide_id += 1
        slide_node["data-slide-id"] = last_slide_id.to_s
      end

      # Response with everything
      output = page.at("body").inner_html
      throw :response, [200, {'Content-Type' => 'text/html'}, output]
    end

    def load_snippet(snippet_name)
      snippet_path = root.join("snippets", snippet_name)
      snippet_html_cached = root.join("tmp", "snippets",
                                      Digest::MD5.new.tap {|digest| digest << snippet_path.read }.hexdigest + ".html")

      if snippet_html_cached.exist? and snippet_html_cached.mtime > snippet_path.mtime

        snippet_html_cached.read

      else

        content =
          begin
            formatter = Rouge::Formatters::HTMLInline.new(Rouge::Themes::Github)
            lexer = Rouge::Lexer.guess_by_filename(snippet_name)
            "<pre>" + formatter.format(lexer.lex(File.read(snippet_path))) + "</pre>"
          rescue => e
            STDERR.puts "\033[31mCould not render snippet #{snippet_name}: #{e}\033[m"
            %[<pre class="raw-snippet">#{ERB::Util.h snippet_path.read}</pre>]
          end

        snippet_html_cached.dirname.mkpath
        snippet_html_cached.open("w") {|f| f.write content }
        content
      end
    end

    def load_asset(asset_name, css_class = [])
      asset_path = assets_root.join(asset_name)
      asset_url = "/assets/#{ERB::Util.h asset_name}"
      asset_type = nil

      if not css_class.empty?
        # Check if the css_class list contains any of the valid classes
        asset_type = (%w(image style javascript) & css_class).first
      end

      if asset_type.nil?
        # If the class attribute has no known class, infer it with the MIME type
        mime_type = MIME::Types.type_for(asset_name).first
        asset_type =
          if (mime_type and mime_type.media_type == "image")
            "image"
          elsif mime_type.to_s == "text/css"
            "style"
          elsif mime_type.to_s == "application/javascript" or asset_path.extname == "coffee"
            "javascript"
          end
      end

      case asset_type
      when "image"
        %[<img class="asset" src="#{asset_url}">]

      when "style"
        %[<link href="#{asset_url}" rel="stylesheet">]

      when "javascript"
        %[<script src="#{asset_url}"></script>]

      else
        %[<a href="#{asset_url}" target="_blank">#{ERB::Util.h asset_name}</script>]
      end

    end
  end
end
