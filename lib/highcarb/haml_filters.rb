require "haml"
require "shellwords"

module HighCarb
  class HamlFilters < Haml::Filters::Base

    CUSTOM_FILTERS = {}

    Filter = Struct.new(
      :root,
      :logger,
      :stream,
      :command,
      :bg_process
    )

    def self.register_all(root, logger, filters)
      filters.each_pair do |name, command|
        stream = false
        if command =~ /\Astream:(.*)\Z/m
          command = $1
          stream = true
        end

        CUSTOM_FILTERS[name.to_s] = Filter.new(root, logger, stream, Shellwords.split(command), nil)
        Haml::Filters.registered[name.to_sym] = self
      end
    end

    def compile(node)
      filter = CUSTOM_FILTERS[node.value[:name].to_s]

      if not filter
        raise ArgumentError.new("#{node.inspect} is not a valid filter")
      end

      text = node.value[:text]
      text = text.rstrip unless ::Haml::Util.contains_interpolation?(text) # for compatibility

      html = nil

      # Try to send the note to a background process.
      if child = filter.bg_process
        begin
          child.write("#{text.bytesize}\n#{text}")
          child.flush

          bytesize = Integer(child.readline.chomp)
          html = child.read(bytesize)
        rescue Errno::EPIPE
          filter.logger.error "Process #{child.pid} unavailable."
          Process.waitpid(child.pid)
          filter.bg_process = nil
        end
      end

      # Launch the command if we still don't have the HTML
      if html.nil?
        child = IO.popen(filter.command, "r+", chdir: filter.root)

        if filter.stream
          filter.bg_process = child

          child.write("#{text.bytesize}\n#{text}")
          child.flush

          bytesize = Integer(child.readline.chomp)
          html = child.read(bytesize)
        else
          child.write(text)
          child.close_write
          html = child.read

          Process.waitpid(child.pid)
          if not $?.success?
            filter.logger.error "Process for #{filter.command.inspect} failed"
          end
        end
      end

      [:multi, *compile_plain(html)]
    end

    private

    def compile_plain(text)
      string_literal = ::Haml::Util.unescape_interpolation(text)
      Haml::StringSplitter.compile(string_literal).map do |temple|
        type, str = temple
        case type
        when :dynamic
          [:escape, false, [:dynamic, str]]
        else
          temple
        end
      end
    end
  end

end
