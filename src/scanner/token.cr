module Token
  enum Type
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
    And
    Class
    Else
    False
    Fun
    For
    If
    Nil
    Or

    Print
    Return
    Super
    This
    True
    Var
    While

    Eof
  end

  RESERVED = {
    "and"    => Type::And,
    "class"  => Type::Class,
    "else"   => Type::Else,
    "false"  => Type::False,
    "fun"    => Type::Fun,
    "for"    => Type::For,
    "if"     => Type::If,
    "nil"    => Type::Nil,
    "or"     => Type::Or,
    "print"  => Type::Print,
    "return" => Type::Return,
    "super"  => Type::Super,
    "this"   => Type::This,
    "true"   => Type::True,
    "var"    => Type::Var,
    "while"  => Type::While,
  } of String => Type

  def self.reserved?(identifier)
    RESERVED[identifier]?
  end

  struct Token
    def initialize(
      @type : Type,
      @literal : String | Nil | Float32,
      @line : Int32,
      @offset : Int32
    )
    end
  end

  def self.make(*args)
    Token.new(*args)
  end
end
