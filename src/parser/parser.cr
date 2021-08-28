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
      if @current >= @tokens.size
        @tokens.last(1)[0]
      else
        @tokens[@current]
      end
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
        raise invalid(message)
      else
        move
        previous
      end
    end

    def syncronise
      # TODO: if current is EOF, this should throw
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
        consume(Token::Type::RightParen, "Expected ')' after expression")
        Ast::Grouping.new(expr)
      elsif match(Token::Type::Identifier)
        Ast::Variable.new(previous)
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

    def assignment
      expr = equality

      if match(Token::Type::Equal)
        equals = previous
        # This allows for a = b = 3 assignments
        value = assignment

        if expr.is_a?(Ast::Variable)
          Ast::Assign.new(expr.name, value)
        else
          raise invalid("Invalid assignment target")
        end
      else
        expr
      end
      # http://www.craftinginterpreters.com/statements-and-state.html
    end

    def expression
      assignment
    end

    def print_st
      expr = expression
      consume(Token::Type::SemiColon, "Expected ';' after value")
      Ast::Print.new(expr)
    end

    def expression_st
      expr = expression
      consume(Token::Type::SemiColon, "Expected ';' after value")
      expr
    end

    def statement
      if match(Token::Type::Print)
        print_st
      else
        expression_st
      end
    end

    def var
      name = consume(Token::Type::Identifier, "Expect variable name.")
      initializer =
        if match(Token::Type::Equal)
          expression
        else
          nil
        end
      consume(Token::Type::SemiColon, "Expected ';' after variable declaration")
      Ast::Var.new(name, initializer)
    end

    def declaration
      begin
        if match(Token::Type::Var)
          var
        else
          statement
        end
      rescue ex
        puts ex.message
        syncronise
        nil
      end
    end

    def parse
      acc = [] of Ast::Expression
      begin
        while !done
          if item = declaration
            acc << item
          end
        end
        acc
      rescue ex
        puts ex.message
        exit(-1)
      end
    end
  end
end
