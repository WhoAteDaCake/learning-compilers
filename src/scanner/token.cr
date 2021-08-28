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

  # Tokens, which can be a starting point
  # after we ecounter a syntax error
  SYNC_TOKENS = [
    Type::Class,
    Type::Return,
    Type::Fun,
    Type::Var,
    Type::While,
    Type::For,
    Type::If,
    Type::Print,
  ]

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

  def self.is_sync?(type)
    SYNC_TOKENS.includes?(type)
  end

  def self.reserved?(identifier)
    RESERVED[identifier]?
  end

  struct Token
    property type, literal

    def initialize(
      @type : Type,
      @literal : String | Float32,
      @line : Int32,
      @offset : Int32
    )
    end

    def name : String
      if @literal.is_a?(String)
        @literal.as(String)
      else
        raise "Tried to access non string name"
      end
    end

    def display
      @literal.to_s
    end

    def to_s
      "#{type} @ (#{@line + 1},#{@offset + 1})"
    end
  end

  def self.make(*args)
    Token.new(*args)
  end
end
