module Parser
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
