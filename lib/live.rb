require 'tempfile'
require 'highline'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'ext/object'

module Live 
  class Notice < String; end
  
  class Session
    include HighLine::SystemExtensions
    attr_reader :path
    
    # Starts a live session using a named pipe to receive code from a remote source and evaluates it within a context, a bit like an IRB session but evaluates code sent from a text editor
    def initialize path = "#{Dir.tmpdir}/live-rb" 
      raise Exception.new("Another session sems to be running: #{path}") if File.exist? path
      puts Notice.new("Live Session: #{path}")

      %x{mkfifo #{path}}
      @pipe, @path, @key_bindings = File.open(path, 'r+'), path, {}

      begin
        get_binding and key_listen and run!
      ensure
        quit!
      end
    end

    def safe_eval *args
      begin
        eval *args
      rescue Exception => exception
        SystemExit === exception ? quit! : exception
      end
    end

    def quit!
      File.delete(@path) && exit
    end
    
    # Starts a loop that checks the named pipe and evaluate its contents, will be called on initialize
    def run! 
      loop { puts safe_eval(@pipe.gets, @context) }
    end
  
    def puts obj
      super obj.colored_inspect
      # Hackish solution for cursor position
      super "\e[200D"
      super "\e[2A"
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
    
    # Binds a proc to a keystroke
    def bind_key key, &block
      @key_bindings[key.to_s.unpack('c').first] = block
      Notice.new "Key '#{key}' is bound to an action" if block
    end
    
    def get_binding
      @context = binding
    end
    
    alias :reload! :get_binding
  end
end
