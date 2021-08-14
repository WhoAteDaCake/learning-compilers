require "./token"

# Future:
# - An interface for ErrorReported, which could be swapped out
# - anything from stdout, to in memory one
class Scanner
  @failed = false

  def initialize(@raw : String)
    output = scan(@raw)
    puts output
  end

  def report(line, char, message)
    puts "(#{line + 1},#{char + 1}) Error: #{message}"
    @failed = true
  end

  def scan_char(reader, ch)
    # NOTE: would dictionary be better here?
    if ch == '('
      TType::LeftParen
    elsif ch == ')'
      TType::RightParen
    elsif ch == '{'
      TType::LeftBrace
    elsif ch == '}'
      TType::RightBrace
    elsif ch == ','
      TType::Comma
    elsif ch == '.'
      TType::Dot
    elsif ch == '-'
      TType::Minus
    elsif ch == '+'
      TType::Plus
    elsif ch == ';'
      TType::SemiColon
    elsif ch == '*'
      TType::Star
    elsif ch == '!'
      if reader.move_if('=')
        TType::BangEqual
      else
        TType::Bang
      end
    elsif ch == '='
      if reader.move_if('=')
        TType::EqualEqual
      else
        TType::Equal
      end
    elsif ch == '<'
      if reader.move_if('=')
        TType::LessEqual
      else
        TType::Less
      end
    elsif ch == '>'
      if reader.move_if('=')
        TType::GreaterEqual
      else
        TType::Greater
      end
    elsif ch == '/'
      if reader.move_if('/')
        TType::Comment
      else
        TType::Slash
      end
    elsif ch.ascii_whitespace?
      TType::WhiteSpace
    elsif ch == '"'
      TType::String
    elsif ch.ascii_number?
      TType::Number
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
      break if !reader.has_next?
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

  # TODO:
  # - Support of multi-line strings
  def scan_line(line, line_idx)
    if line.size == 0
      [] of Token
    else
      reader = SafeReader.new(line)
      acc = [] of Token
      loop do
        pos = reader.pos
        tkn_type = scan_char(reader, reader.current_char)
        if tkn_type
          # Comments skip the rest of the line
          if tkn_type == TType::Comment
            break
          elsif tkn_type == TType::String
            end_pos = read_string(reader)
            if end_pos != -1
              acc << Token.new(tkn_type, line[pos + 1, end_pos - 1], line_idx, pos)
            else
              report(line_idx, pos, "Unterminated string")
              exit(1)
            end
          elsif tkn_type == TType::Number
            #
            end_pos = read_number(reader)
            if end_pos != -1
              acc << Token.new(tkn_type, line[pos, end_pos + 1].to_f32, line_idx, pos)
            else
              report(line_idx, pos, "Invalid number")
              exit(1)
            end
          elsif tkn_type != TType::WhiteSpace
            acc << Token.new(tkn_type, nil, line_idx, pos)
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

  def scan(source)
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
    tokens << Token.new(TType::EOF, nil, lines.size - 1, eof_offset)
    tokens
  end
end
