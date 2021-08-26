module Ast
  macro ast(name, *properties)
	  class {{name.id}} < Expression
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

  ast Binary,
    left : Expression,
    operator : Token::Token,
    right : Expression do
    def display
      "#{@left.display} #{@operator.display} #{@right.display}"
    end
  end

  ast Grouping,
    expr : Expression do
    def display
      "(#{@expr.display})"
    end
  end

  ast Literal,
    value : String | Float32 | Bool | Nil do
    def display
      "#{@value}"
    end
  end

  ast Unary,
    operator : Token::Token,
    right : Expression do
    def display
      "(#{@operator.display} #{@right.display})"
    end
  end

  ast Print,
    expr : Expression

  alias Stmt = Expression | Print
  # ast Stmt,
  #   expr : Expression,
  #   print : Expression do
  #   def display
  #     "TODO"
  #   end
  # end
end
