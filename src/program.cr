require "./scanner/*"
require "./ast/*"
require "./parser/*"
require "./interpreter/*"

module Program
  def self.run
    scanner = Scanner.new(ARGF.gets_to_end)
    tokens = scanner.scan

    parser = Parser::Parser.new(tokens)
    ast = parser.parse

    pp! ast
    interpreter = Interpreter::Interpreter.new(ast)
    puts "Output: #{interpreter.run}"
    # puts ast.display
  end
end

Program.run
