require 'tempfile'
require 'highline'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'ext/object'

module Live 
  class Notice < String; end

  class Context
    def initialize session
      @session = session
      @binding = binding
    end

    def eval string
      begin
        super string, @binding
      rescue Exception => exception
        SystemExit === exception ? quit! : exception
      end
    end

    # Binds a proc to a keystroke
    def bind_key key, &block
      @session.key_bindings[key.to_s.unpack('c').first] = block
      Notice.new "Key '#{key}' is bound to an action" if block
    end

    def quit!
      @session.quit!
    end

    def reset!
      @session.key_bindings.clear
      @session.new_context
    end
  end
  
  class Session
    include HighLine::SystemExtensions
    attr_reader :path, :key_bindings
    
    # Starts a live session using a named pipe to receive code from a remote source and evaluates it within a context, a bit like an IRB session but evaluates code sent from a text editor
    def initialize path = "#{Dir.tmpdir}/live-rb" 
      raise Exception.new("Another session sems to be running: #{path}") if File.exist? path
      puts Notice.new("Live Session: #{path}")

      %x{mkfifo #{path}}
      @pipe, @path, @key_bindings = File.open(path, 'r+'), path, {}

      begin
        new_context and key_listen and run!
      ensure
        File.delete(path) if File.exists? path
      end
    end

    def quit!
      File.delete(@path) && exit
    end
  
    def puts obj
      super obj.colored_inspect
      # Hackish solution for cursor position
      super "\e[200D"
      super "\e[2A"
    end

    def new_context
      @context = Context.new(self)
    end

    private
    # Starts a loop that checks the named pipe and evaluate its contents, will be called on initialize
    def run! 
      loop { puts @context.eval(@pipe.gets) }
    end

    # Listen for keystrokes and calls bound procs
    def key_listen
      Thread.new do
        loop do 
          block = @key_bindings[get_character]
          puts block.call if block
        end
      end
    end
  end
end
