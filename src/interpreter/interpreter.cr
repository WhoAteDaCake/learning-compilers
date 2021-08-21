module Interpreter
  alias Literal = String | Float32 | Bool | Nil

  class Interpreter
    def initialize(@ast : Ast::Expression)
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

    def evaluate(ast : Ast::Literal)
      ast.value
    end

    def evaluate(ast : Ast::Grouping)
      evaluate(ast.expr)
    end

    def evaluate(ast : Ast::Unary)
      val = evaluate(ast.right)
      if ast.operator == Token::Type::Minus
        val.as(Float32) * -1
      elsif ast.operator == Token::Type::Bang
        !is_truthy(val)
      else
        nil
      end
    end

    def evaluate(ast : Ast::Binary)
      left = evaluate(ast.left)
      right = evaluate(ast.right)
      op = ast.operator.type

      if op == Token::Type::Minus
        left.as(Float32) - right.as(Float32)
      elsif op == Token::Type::Slash
        left.as(Float32) - right.as(Float32)
      elsif op == Token::Type::Star
        left.as(Float32) * right.as(Float32)
      elsif op == Token::Type::Plus
        if left.is_a?(String) && right.is_a?(String)
          left.as(String) + right.as(String)
        elsif left.is_a?(Float32) && right.is_a?(Float32)
          left.as(Float32) + right.as(Float32)
        else
          nil
        end
      elsif op == Token::Type::Greater
        left.as(Float32) > right.as(Float32)
      elsif op == Token::Type::GreaterEqual
        left.as(Float32) >= right.as(Float32)
      elsif op == Token::Type::Less
        left.as(Float32) < right.as(Float32)
      elsif op == Token::Type::LessEqual
        left.as(Float32) <= right.as(Float32)
      elsif op == Token::Type::BangEqual
        !(left == right)
      elsif op == Token::Type::EqualEqual
        left == right
      else
        nil
      end
    end

    def run
      evaluate(@ast)
    end
  end
end
