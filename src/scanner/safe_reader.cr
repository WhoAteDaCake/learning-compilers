class SafeReader
  @reader : Char::Reader

  delegate next_char, to: @reader
  delegate has_next?, to: @reader
  delegate peek_next_char, to: @reader
  delegate pos, to: @reader
  # delegate pos, to: @reader
  delegate current_char, to: @reader

  def initialize(line : String)
    @reader = Char::Reader.new(line)
  end

  def pos=(idx)
    @reader.pos = idx
    puts "#{@reader.pos}, #{idx}"
  end

  def peek_next_char?
    if has_next?
      peek_next_char
    else
      nil
    end
  end

  def next_is(char)
    peek_next_char? == char
  end

  def move_if(char)
    if next_is(char)
      # Move once since we'll move after in new loop
      next_char
      true
    else
      false
    end
  end
end
