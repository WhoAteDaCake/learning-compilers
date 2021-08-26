require "./scanner/*"
require "./ast/*"
require "./parser/*"
require "./interpreter/*"

module Program
  def self.run
    scanner = Scanner.new(ARGF.gets_to_end)
    tokens = scanner.scan

    # puts tokens
    parser = Parser::Parser.new(tokens)
    statements = parser.parse

    # pp! ast
    # interpreter = Interpreter::Interpreter.new(ast)
    # puts "Output: [#{interpreter.run}]"
    # puts ast.display
  end
end

Program.run
