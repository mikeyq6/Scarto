class Player
  attr_accessor :name, :cards, :tricks
  @@COMPUTER = 1
  @@HUMAN = 2

  attr_reader :id

  def initialize
  def self.COMPUTER
    @@COMPUTER
  end
  def self.HUMAN
    @@HUMAN
  end

    @tricks = []
  end
end
