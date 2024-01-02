require_relative "state"
require_relative "trick"
require_relative "player"
require_relative "card"

class Game
  attr_accessor :players, :deck
  attr_reader :id, :state

  def initialize
    @state = State.new
    @players = []
    @deck = []
    create_deck()
  end

  def create_deck
    Card.suits.each do |suit|

      if suit == "Trumps"
        [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21].each do |num|
          deck.push(
            Card.new(suit, num)
          )
        end
      else
        [1,2,3,4,5,6,7,8,9,10, "Knave", "Knight", "Queen", "King"].each do |num|
          deck.push(
            Card.new(suit, num)
          )
        end
      end
    end
  end

  def display_deck
    @deck.each do |card|
      puts "#{card}"
    end
  end
end

g = Game.new
g.display_deck
