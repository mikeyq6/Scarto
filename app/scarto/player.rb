class Player
  @@COMPUTER = 1
  @@HUMAN = 2

  attr_accessor :name, :hand, :tricks, :type, :score
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
    @score = 0
  end

  def has_matto_trick
    if tricks.find { |t| t[0].suit == Card.suits[4] && t[0].number == 0 }
        return true
    end

    false
  end

  def sort_hand
    len = @hand.size
    index = 0

    @hand.each do |card|
      swapped = false

      (0..(len-index-2)).each do |j|
        if @hand[j].is_greater_than_with_suit(@hand[j+1])
          tc = @hand[j]
          @hand[j] = @hand[j+1]
          @hand[j+1] = tc
          swapped = true
        end
      end

      if !swapped
        break
      end

      index = index + 1
    end
  end

end
