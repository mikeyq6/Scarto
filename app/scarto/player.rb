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

  def has_matto_trick
    if tricks.find { |t| t[0].suit == Card.suits[4] && t[0].number == 0 }
        return true
    end

    false
  end

end
