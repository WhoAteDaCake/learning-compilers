module Interpreter
  class Environment
    property values = Hash(Ast::Value).new

    def initialize
    end

    def define(key : String, value : Ast::Value)
      @values[key] = value
    end

    def get(key : Token::Token)
    	if value = @values?(key.name)
    		value
    	else
    		raise RuntimeException("Undefined variable: #{key.display}")
    	end
    end
  end
end
