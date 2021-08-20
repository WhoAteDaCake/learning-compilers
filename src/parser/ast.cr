module Parser
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
    right : Expression

  ast Grouping,
    expr : Expression

  ast Literal,
    value : Token::Token

  ast Unary,
    operator : Token::Token,
    right : Expression
end
