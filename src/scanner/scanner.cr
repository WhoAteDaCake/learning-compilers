require "./token"

# Future:
# - An interface for ErrorReported, which could be swapped out
# - anything from stdout, to in memory one
class Scanner
  @failed = false

  def initialize(@raw : String)
    puts @raw
  end

  def report(line, where, message)
    puts "[line #{line}] Error: #{where}: #{message}"
    @failed = true
  end

  def error(line, message)
    report(line, "", message)
  end

  def scan_line(line)
    [] of Token
  end

  def scan(source)
    line, tokens = source.lines.reduce({1, [] of Token}) do |acc, row|
      line, ls = acc
      ls = ls + scan_line(row)
      # Each new line adds 1 offset
      {line + 1, ls}
    end
    tokens << Token.new(EOF, "", nil, line, -1)
    tokens
  end
end
