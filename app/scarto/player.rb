class Player
  @@COMPUTER = 1
  @@HUMAN = 2

  attr_accessor :name, :hand, :tricks, :type
  attr_reader :id

  def self.COMPUTER
    @@COMPUTER
  end
  def self.HUMAN
    @@HUMAN
  end

  def initialize(player_type, player_name)
    @type = player_type
    @name = player_name
    @tricks = []
    @hand = []
  end
end
