require_relative "card"

class Trick
  attr_accessor :cards, :first_player, :winning_player

  def initialize
    @cards = []
  end
end
