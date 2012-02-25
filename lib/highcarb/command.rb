
require "trollop"

require "highcarb"
require "highcarb/generator"
require "highcarb/services"

module HighCarb
  class Command
    attr_reader :options
    attr_reader :command_line
    attr_reader :args

    def initialize
      @command_line = @args = []
      @options = {}
    end

    def parse!(args)
      @command_line = args.dup
      @args = args
      @options = Trollop.options(@args) do
        opt "generate", "Generate a new highcarb project"
        opt "server", "Start the servers (default action). See --http-port and --ws-port"
        opt "http-port", "HTTP server port", default: 9090
        opt "ws-port", "WebSockets port", default: 9091
      end

      self
    end

    def run!
      if args.size != 1
        STDERR.puts "Please indicate the project path as an extra argument of the command. For example:"
        STDERR.puts "$ \033[1m#$0 #{command_line * " "} project-path/\033[m"
        exit 1
      end

      if options["generate"]
        # Generate a new project
        HighCarb::Generator.new(self, args.first).run!
      else
        HighCarb::Services.start!(self)
      end

    rescue HighCarb::Error => error
      STDERR.puts "ERROR: " + error.message
    end
  end
end
