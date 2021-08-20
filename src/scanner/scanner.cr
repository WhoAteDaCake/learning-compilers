require "./token"

# Future:
# - An interface for ErrorReported, which could be swapped out
# - anything from stdout, to in memory one
class Scanner
  @failed = false

  def initialize(@raw : String)
  end

  def report(line, char, message)
    puts "(#{line + 1},#{char + 1}) Error: #{message}"
    @failed = true
  end

  def scan_char(reader, ch)
    # NOTE: would dictionary be better here?
    if ch == '('
      Token::Type::LeftParen
    elsif ch == ')'
      Token::Type::RightParen
    elsif ch == '{'
      Token::Type::LeftBrace
    elsif ch == '}'
      Token::Type::RightBrace
    elsif ch == ','
      Token::Type::Comma
    elsif ch == '.'
      Token::Type::Dot
    elsif ch == '-'
      Token::Type::Minus
    elsif ch == '+'
      Token::Type::Plus
    elsif ch == ';'
      Token::Type::SemiColon
    elsif ch == '*'
      Token::Type::Star
    elsif ch == '!'
      if reader.move_if('=')
        Token::Type::BangEqual
      else
        Token::Type::Bang
      end
    elsif ch == '='
      if reader.move_if('=')
        Token::Type::EqualEqual
      else
        Token::Type::Equal
      end
    elsif ch == '<'
      if reader.move_if('=')
        Token::Type::LessEqual
      else
        Token::Type::Less
      end
    elsif ch == '>'
      if reader.move_if('=')
        Token::Type::GreaterEqual
      else
        Token::Type::Greater
      end
    elsif ch == '/'
      if reader.move_if('/')
        Token::Type::Comment
      else
        Token::Type::Slash
      end
    elsif ch.ascii_whitespace?
      Token::Type::WhiteSpace
    elsif ch == '"'
      Token::Type::String
    elsif ch.ascii_number?
      Token::Type::Number
    elsif ch.ascii_letter?
      Token::Type::Identifier
    else
      nil
    end
  end

  def read_string(reader)
    end_i = -1
    loop do
      reader.next_char
      if reader.current_char == '"'
        end_i = reader.pos
        break
      end
      break unless reader.has_next?
    end
    end_i
  end

  # Should return enum for clearer error message?
  def read_number(reader)
    end_i = -1
    loop do
      ch = reader.current_char
      if ch.ascii_number?
        end_i = reader.pos
      elsif ch == '.' && reader.peek_next_char?.try &.ascii_number?
        reader.next_char
        end_i = reader.pos
      else
        break
      end
      break unless reader.has_next?
      reader.next_char
    end
    end_i
  end

  def read_identifier(reader)
    end_i = -1
    loop do
      if reader.current_char.alphanumeric?
        end_i = reader.pos
      else
        break
      end
      break unless reader.has_next?
      reader.next_char
    end
    end_i
  end

  # TODO:
  # - Support of multi-line strings
  # - There should be a better approach here ?
  def scan_line(line, line_idx)
    if line.size == 0
      [] of Token::Token
    else
      reader = SafeReader.new(line)
      acc = [] of Token::Token
      loop do
        pos = reader.pos
        tkn_type = scan_char(reader, reader.current_char)
        if tkn_type
          # Comments skip the rest of the line
          if tkn_type == Token::Type::Comment
            break
          elsif tkn_type == Token::Type::String
            end_pos = read_string(reader)
            if end_pos != -1
              acc << Token.make(tkn_type, line[(pos + 1)..(end_pos - 1)], line_idx, pos)
            else
              report(line_idx, pos, "Unterminated string")
              exit(1)
            end
          elsif tkn_type == Token::Type::Number
            #
            end_pos = read_number(reader)
            if end_pos != -1
              acc << Token.make(tkn_type, line[pos..end_pos].to_f32, line_idx, pos)
            else
              report(line_idx, pos, "Invalid number")
              exit(1)
            end
          elsif tkn_type == Token::Type::Identifier
            #
            end_pos = read_identifier(reader)
            if end_pos != -1
              id = line[pos..end_pos]
              tkn_type =
                if val = Token.reserved?(id)
                  val
                else
                  tkn_type
                end
              acc << Token.make(tkn_type, id, line_idx, pos)
            else
              report(line_idx, pos, "Invalid identifier")
              exit(1)
            end
          elsif tkn_type != Token::Type::WhiteSpace
            acc << Token.make(tkn_type, line[(pos)..(reader.pos)], line_idx, pos)
          end
        else
          report(line_idx, pos, "Unexpected char: [#{reader.current_char}]")
          exit(1)
        end
        # Is it a bug in reader?
        break if !reader.has_next? || reader.pos == line.size - 1
        reader.next_char
      end
      acc
    end
  end

  # At the moment, we have no way to support multiline strings
  # or comments.
  def scan
    source = @raw
    lines = source.lines
    # map with index could also work here?
    tokens = lines.map_with_index do |row, line_idx|
      scan_line(row, line_idx)
    end
    # This is important for later iterations
    tokens = tokens.flatten
    # Handles empty files
    eof_offset =
      if lines.size > 0
        lines.last(1).size - 1
      else
        # Make -1 here, so we don't try to access by mistake
        -1
      end
    tokens << Token.make(Token::Type::Eof, "EOF", lines.size - 1, eof_offset)
    tokens
  end
end
