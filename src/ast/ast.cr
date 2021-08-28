module Ast
  macro ast(type, name, *properties)
	  class {{name.id}} < {{type.id}}
	    {% for property in properties %}
	      {% if property.is_a?(Assign) %}
	        getter {{property.target.id}}
	      {% elsif property.is_a?(TypeDeclaration) %}
	        getter {{property}}
	      {% else %}
	        getter :{{property.id}}
	      {% end %}
	    {% end %}

	    def initialize({{
                      *properties.map do |field|
                        "@#{field.id}".id
                      end
                    }})
	    end

	    {{yield}}
	  end
	end

  abstract class Expression
  end

  ast Expression, Binary,
    left : Expression,
    operator : Token::Token,
    right : Expression do
    def display
      "#{@left.display} #{@operator.display} #{@right.display}"
    end
  end

  ast Expression, Grouping,
    expr : Expression do
    def display
      "(#{@expr.display})"
    end
  end

  ast Expression, Literal,
    value : String | Float32 | Bool | Nil do
    def display
      "#{@value}"
    end
  end

  ast Expression, Unary,
    operator : Token::Token,
    right : Expression do
    def display
      "(#{@operator.display} #{@right.display})"
    end
  end

  ast Expression, Variable,
    name : Token::Token do
    def display
      @name.display
    end
  end

  ast Expression, Assign,
    name : Token::Token,
    value : Expression do
    def display
      "#{@name.display} = #{@value.display}"
    end
  end

  abstract class Statement
  end

  ast Statement, Stmt,
    expr : Expression do
    def display
      "#{expr.display};"
    end
  end

  ast Statement, Print,
    expr : Expression do
    def display
      "print(#{@expr})"
    end
  end

  ast Statement, Var,
    name : Token::Token,
    initializer : Expression? do
    def display
      "var #{@name.display} = #{@initializer.display}"
    end
  end

  ast Statement, Block,
    statements : Array(Statement) do
    def display
      (statements.map &.display).join('\n')
    end
  end

  ast Statement, If,
    cond : Expression,
    then_branch : Statement,
    else_branch : Statement? do
    def display
      "if (#{@cond.display}) {\n#{@then_branch.display}\n} else {\n#{@else_branch.try &.display}\n}"
    end
  end

  alias Value = String | Float32 | Bool | Nil
end
