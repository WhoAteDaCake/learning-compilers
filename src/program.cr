require "./scanner/*"
require "./ast/*"
require "./parser/*"

module Program
  def self.run
    scanner = Scanner.new(ARGF.gets_to_end)
    tokens = scanner.scan
    puts tokens
  end
end

Program.run
