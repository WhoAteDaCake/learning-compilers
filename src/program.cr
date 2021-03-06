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
    ast = parser.parse

    # puts ast
    eval = Interpreter::Interpreter.new(ast)
    result = eval.run
    # puts "Output: [#{result}]"
    # puts ast.display
  end
end

Program.run
