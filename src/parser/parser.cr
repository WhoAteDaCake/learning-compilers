module Parser
  class InvalidToken < Exception
  end

  class Parser
    @current = 0

    def initialize(@tokens : Array(Token::Token))
    end

    def move
      @current += 1
    end

    def current
      @tokens[@current]
    end

    def previous
      @tokens[@current - 1]
    end

    def done
      current.type == Token::Type::Eof
    end

    def invalid(message)
      InvalidToken.new("Invalid token: #{current.to_s}.\n#{message}")
    end

    def consume(expected, message)
      if current.type != expected
        invalid(message)
      else
        move
        nil
      end
    end

    def syncronise
      move
      while !done
        if previous.type == Token::Type::SemiColon ||
           Token.is_sync?(current.type)
          break
        end
        move
      end
    end

    # Will attempt to match to any of the provided tokens
    def match(*token_types)
      if found = token_types.includes?(@tokens[@current]?.try &.type)
        move
        found
      end
    end

    def primary
      if match(Token::Type::False)
        Ast::Literal.new(false)
      elsif match(Token::Type::True)
        Ast::Literal.new(true)
      elsif match(Token::Type::Nil)
        Ast::Literal.new(nil)
      elsif match(Token::Type::Number, Token::Type::String)
        Ast::Literal.new(previous.literal)
      elsif match(Token::Type::LeftParen)
        expr = expression
        err = consume(Token::Type::RightParen, "Expected ')' after expression")
        if err
          raise err
        end
        Ast::Grouping.new(expr)
      else
        raise invalid("Expected expression")
      end
    end

    def unary
      if match(Token::Type::Bang, Token::Type::Minus)
        Ast::Unary.new(previous, unary)
      else
        primary
      end
    end

    def factor
      expr = unary
      while match(Token::Type::Slash, Token::Type::Star)
        expr = Ast::Binary.new(expr, previous, unary)
      end
      expr
    end

    def term
      expr = factor
      while match(Token::Type::Minus, Token::Type::Plus)
        expr = Ast::Binary.new(expr, previous, factor)
      end
      expr
    end

    def comparison
      expr = term
      while match(
              Token::Type::Greater,
              Token::Type::GreaterEqual,
              Token::Type::Less,
              Token::Type::LessEqual
            )
        expr = Ast::Binary.new(expr, previous, term)
      end
      expr
    end

    def equality
      expr = comparison

      while match(Token::Type::BangEqual, Token::Type::EqualEqual)
        expr = Ast::Binary.new(expr, previous, comparison)
      end
      expr
    end

    def expression
      equality()
    end

    def print_st
      expr = expression
      err = consume(Token::Type::SemiColon, "Expected ';' after value")
      if err
        raise err
      else
        Ast::Print.new(expr)
      end
    end

    def expression_st
      expr = expression
      err = consume(Token::Type::SemiColon, "Expected ';' after value")
      if err
        raise err
      else
        expr
      end
    end

    def statement
      if match(Token::Type::Print)
        print_st
      else
        expression_st
      end
    end

    def parse
      acc = [] of Ast::Stmt
      begin
        while !done
          acc << statement
        end
        acc
      rescue ex
        puts ex.message
        exit(-1)
      end
    end
  end
end
