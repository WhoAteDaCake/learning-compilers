require "./scanner/*"

module Program
  def self.run
    scanner = Scanner.new(ARGF.gets_to_end)
  end
end

Program.run
