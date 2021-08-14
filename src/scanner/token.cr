enum TType
  # Special
  Comment
  WhiteSpace

  # Single-character tokens.
  LeftParen
  RightParen
  LeftBrace
  RightBrace

  Comma
  Dot
  Minus
  Plus
  SemiColon
  Slash
  Star

  # One or two character tokens.
  Bang
  BangEqual

  Equal
  EqualEqual

  Greater
  GreaterEqual

  Less
  LessEqual

  # Literals.
  Identifier
  String
  Number

  # Keywords.
  AND
  CLASS
  ELSE
  FALSE
  FUN
  FOR
  IF
  NIL
  OR

  PRINT
  RETURN
  SUPER
  THIS
  TRUE
  VAR
  WHILE

  EOF
end

struct Token
  def initialize(
    @type : TType,
    @literal : String | Nil | Float32,
    @line : Int32,
    @offset : Int32
  )
  end
end
