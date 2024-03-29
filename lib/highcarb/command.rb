require "io/console"
require "logger"
require "optimist"

require "highcarb"
require "highcarb/generator"
require "highcarb/haml_filters"
require "highcarb/services"

module HighCarb
  class Command
    attr_reader :options
    attr_reader :command_line
    attr_reader :args

    def initialize
      @command_line = @args = []
      @options = {}
      @logger = Logger.new(STDERR).tap {|logger| logger.level = Logger::INFO }
    end

    def parse!(args)
      @command_line = args.dup
      @args = args
      @options = Optimist.options(@args) do
        opt "generate", "Generate a new highcarb project"

        opt "server", "Start the servers (default action). See --http-port."

        opt "http-port", "HTTP server port", default: 9090

        opt "verbose", "Be verbose"

        opt "auth", "Require auth to access", default: ""
      end

      if @options["verbose"]
        @logger.level = Logger::DEBUG
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
        auth = nil
        if not options["auth"].empty?
          user, password = options["auth"].split(":", 2)
          if password.nil?
            print "Type the password for #{user}: "
            $stdout.flush
            password = $stdin.noecho { $stdin.readline.chomp }
          end

          auth = [ user, password ]
        end

        HighCarb::Services.start!(self, @logger, auth)
      end

    rescue HighCarb::Error => error
      STDERR.puts "ERROR: " + error.message
    end
  end
end
