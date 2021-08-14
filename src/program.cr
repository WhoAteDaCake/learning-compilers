require "./scanner/*"

module Program
  def self.run
    scanner = Scanner.new(ARGF.gets_to_end)
    tokens = scanner.scan
  end
end

Program.run
