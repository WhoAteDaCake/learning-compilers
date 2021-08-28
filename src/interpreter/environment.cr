module Interpreter
  class Environment
    # Parent environment
    property enclosing : Environment?
    property values = Hash(String, Ast::Value).new

    def initialize
    end

    def initialize(@enclosing)
    end

    def define(key : Token::Token, value : Ast::Value)
      @values[key.name] = value
    end

    def redefine(key : Token::Token, value : Ast::Value)
      if @values[key.name]?
        define(key, value)
        # If not in current scope, we can re-define a later variable
      elsif parent = @enclosing
        parent.redefine(key, value)
      else
        raise RuntimeException.new("Assignment to undefined variable: #{key.display}")
      end
    end

    def get(key : Token::Token)
      if value = @values[key.name]?
        value
      elsif parent = @enclosing
        parent.get(key)
      else
        raise RuntimeException.new("Undefined variable: #{key.display}")
      end
    end
  end
end
