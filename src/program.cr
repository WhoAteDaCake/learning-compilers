require "./scanner/*"
require "./ast/*"
require "./parser/*"

module Program
  def self.run
    scanner = Scanner.new(ARGF.gets_to_end)
    tokens = scanner.scan

    parser = Parser::Parser.new(tokens)
    ast = parser.parse
    puts ast.display
  end
end

Program.run
