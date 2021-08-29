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

    def current_is?(type)
      @tokens[@current]?.try &.type == type
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

    def and_expr
      expr = equality
      while match(Token::Type::And)
        op = previous
        right = equality
        expr = Ast::Logical.new(expr, op, right)
      end
      expr
    end

    def or_expr
      expr = and_expr
      while match(Token::Type::Or)
        op = previous
        right = and_expr
        expr = Ast::Logical.new(expr, op, right)
      end
      expr
    end

    # expression     → assignment ;
    # assignment     → IDENTIFIER "=" assignment
    #                | logic_or ;
    # logic_or       → logic_and ( "or" logic_and )* ;
    # logic_and      → equality ( "and" equality )* ;
    def assignment
      expr = or_expr

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
      Ast::Stmt.new(expr)
    end

    def block
      st = [] of Ast::Statement
      while !(done || current_is?(Token::Type::RightBrace))
        # There are cases like synch where we might return a nil
        if decl = declaration
          st << decl
        end
      end
      consume(Token::Type::RightBrace, "Expected '}' after block")
      Ast::Block.new(st)
    end

    def if_statement
      consume(Token::Type::LeftParen, "Expected '(' before expression")
      cond = expression
      consume(Token::Type::RightParen, "Expected ')' after the expression")
      then_branch = statement
      else_branch =
        if match(Token::Type::Else)
          statement
        else
          nil
        end
      Ast::If.new(cond, then_branch, else_branch)
    end

    def while_st
      consume(Token::Type::LeftParen, "Expected '(' before while expression")
      expr = expression
      consume(Token::Type::RightParen, "Expected ')' after while expression")
      body = statement
      Ast::While.new(expr, body)
    end

    # statement      → exprStmt
    #                | ifStmt
    #                | printStmt
    #                | whileStmt
    #                | block ;

    # whileStmt      → "while" "(" expression ")" statement ;
    def statement
      if match(Token::Type::If)
        if_statement
      elsif match(Token::Type::While)
        while_st
      elsif match(Token::Type::Print)
        print_st
      elsif match(Token::Type::LeftBrace)
        block
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
      acc = [] of Ast::Statement
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
