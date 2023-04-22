require "haml"
require "shellwords"

module HighCarb
  class HamlFilters < Haml::Filters::Base

    CUSTOM_FILTERS = {}

    Filter = Struct.new(:root, :logger, :command)

    def self.register_all(root, logger, filters)
      filters.each_pair do |name, command|
        CUSTOM_FILTERS[name.to_s] = Filter.new(root, logger, Shellwords.split(command))
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

      child = IO.popen(filter.command, "r+", chdir: filter.root)
      child.write(text)
      child.close_write
      html = child.read

      Process.waitpid(child.pid)
      if not $?.success?
        filter.logger.error "Process for #{filter.command.inspect} failed"
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
