class Object
  # Outputs an ANSI colored string with the object representation
  def colored_inspect
    case self
    when Exception
      "\e[41;33m#{self.inspect}\e[0m"
    when Numeric, Symbol, TrueClass, FalseClass, NilClass
      "\e[35m#{self.inspect}\e[0m"
    when Live::Notice
      "\e[42;30m#{self}\e[0m"
    when String
      "\e[32m#{self.inspect}\e[0m"
    when Array
      "[#{ self.collect{ |i| i.colored_inspect}.join(', ') }]"
    when Hash
      "{#{ self.collect{ |i| i.collect{|e| e.colored_inspect}.join(' => ') }.join(', ') }}"
    else
      "\e[36m#{self}\e[0m"
    end
  end
end
