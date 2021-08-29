module Interpreter
  alias Literal = String | Float32 | Bool | Nil

  class InvalidType < Exception
  end

  class Interpreter
    macro safe_cast(value, type)
	  	{{value.id}} =
		  	if {{value.id}}.is_a?({{type.id}})
		  		{{value.id}}.as({{type.id}})
		  	else
		  		raise InvalidType.new("#{token.to_s} expected type: #{{{type.id}}}, received {{value.id}} of type #{{{value.id}}.class}")
		  	end
	  end

    macro safe_op(type, expr)
	  	safe_cast({{expr.receiver.id}}, {{type}})
	  	safe_cast({{expr.args[0].id}}, {{type}})
	  	{{expr.id}}
	  end

    @env = Environment.new

    def initialize(@ast : Array(Ast::Statement))
    end

    def is_truthy(val : Literal) : Bool
      if val.is_a?(Nil)
        false
      elsif val.is_a?(Bool)
        val.as(Bool)
      else
        true
      end
    end

    def evaluate(ast : Ast::Variable)
      @env.get(ast.name)
    end

    def evaluate(ast : Ast::Literal)
      ast.value
    end

    def evaluate(ast : Ast::Grouping)
      evaluate(ast.expr)
    end

    def evaluate(ast : Ast::Unary)
      val = evaluate(ast.right)
      token = ast.operator
      opt = token.type
      if opt == Token::Type::Minus
        safe_cast(val, Float32)
        val * -1
      elsif opt == Token::Type::Bang
        !is_truthy(val)
      else
        nil
      end
    end

    def evaluate(ast : Ast::Binary)
      left = evaluate(ast.left)
      right = evaluate(ast.right)
      token = ast.operator
      op = ast.operator.type

      if op == Token::Type::Minus
        safe_op(Float32, left + right)
      elsif op == Token::Type::Slash
        safe_op(Float32, left / right)
      elsif op == Token::Type::Star
        safe_op(Float32, left * right)
      elsif op == Token::Type::Plus
        if left.is_a?(String) && right.is_a?(String)
          safe_op(String, left + right)
        elsif left.is_a?(Float32) && right.is_a?(Float32)
          safe_op(Float32, left + right)
        else
          nil
        end
      elsif op == Token::Type::Greater
        safe_op(Float32, left > right)
      elsif op == Token::Type::GreaterEqual
        safe_op(Float32, left >= right)
      elsif op == Token::Type::Less
        safe_op(Float32, left < right)
      elsif op == Token::Type::LessEqual
        safe_op(Float32, left <= right)
      elsif op == Token::Type::BangEqual
        !(left == right)
      elsif op == Token::Type::EqualEqual
        left == right
      else
        nil
      end
    end

    def evaluate(ast : Ast::Logical)
      left = evaluate(ast.left)
      if ast.op.type == Token::Type::Or
        if is_truthy(left)
          left
        else
          evaluate(ast.right)
        end
      else
        # If And statment and first expression
        # is false no need to evaluate further
        if !is_truthy(left)
          left
        else
          evaluate(ast.right)
        end
      end
    end

    def evaluate(ast : Ast::Stmt)
      evaluate(ast.expr)
      nil
    end

    def evaluate(ast : Ast::Var)
      value =
        if init = ast.initializer
          evaluate(init)
        else
          nil
        end
      @env.define(ast.name, value)
      nil
    end

    def evaluate(ast : Ast::Assign)
      value = evaluate(ast.value)
      @env.redefine(ast.name, value)
      value
    end

    def evaluate(ast : Ast::Print)
      value = evaluate(ast.expr)
      puts value
      nil
    end

    def evaluate(ast : Ast::Block)
      prev = @env
      @env = Environment.new(prev)
      begin
        ast.statements.each { |s| evaluate(s) }
      ensure
        @env = prev
      end
      nil
    end

    def evaluate(ast : Ast::If)
      if is_truthy(evaluate(ast.cond))
        evaluate(ast.then_branch)
      elsif eb = ast.else_branch
        evaluate(eb)
      end
    end

    def run
      begin
        @ast.map { |s| evaluate(s) }
      rescue ex
        puts "Failed to run"
        puts ex.message
        exit(1)
      end
    end
  end
end
