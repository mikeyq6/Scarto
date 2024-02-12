class Player
  @@COMPUTER = 1
  @@HUMAN = 2

  @@SIMPLE_AI = 0
  @@MODERATE_AI = 1

  attr_accessor :name, :hand, :tricks, :type, :score, :ai_level
  attr_reader :id

  def self.COMPUTER
    @@COMPUTER
  end
  def self.HUMAN
    @@HUMAN
  end
  def self.SIMPLE_AI
    @@SIMPLE_AI
  end
  def self.MODERATE_AI
    @@MODERATE_AI
  end

  def initialize(player_type, player_name)
    @type = player_type
    @name = player_name
    @tricks = []
    @hand = []
    @score = 0
    @ai_level = @@SIMPLE_AI
  end

  def self.from_openstruct(data)
    playerType = data.type
    playerName = data.name
    player = Player.new(playerType, playerName)
    player.score = data.score
    player.ai_level = data.ai_level ? data.ai_level : @@SIMPLE_AI

    data.hand.each do |cardData|
      player.hand.push(Card.from_openstruct(cardData))
    end

    data.tricks.each do |trickData|
      trick = []

      trickData.each do |cardData|
        trick.push(Card.from_openstruct(cardData))
      end

      player.tricks.push(trick)
    end
    
    return player
  end

  def has_matto_trick
    # byebug
    if tricks.find { |t| t.size > 0 && t[0].suit == Card.suits[4] && t[0].number == 0 }
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

  def get_lowest_card_of_suit_with_least_cards_except_trumps
    tabs = {}
    lowest = ""

    if @hand.length == 0
      return nil
    end

    Card.suits.each do |s|
      tabs[s] = @hand.filter { |card| card.suit == s }
      if (lowest == "" || tabs[s].length < tabs[lowest].length) && tabs[s].length > 0 && s != Card.suits[4]
        lowest = s
      end
    end

    if lowest == "" # no suits left except trumps, so get lowest trump
      lowest = Card.suits[4]
    end

    return tabs[lowest][0]
  end

  def get_lowest_card_of_suit_higher_than(targetCard)
    matching = @hand.filter { |card| card.suit == targetCard.suit && card.is_greater_than(targetCard) }

    return matching.size > 0 ? matching[0] : nil
  end
end
