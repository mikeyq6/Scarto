class Card

  @@suits = [ "Swords", "Cups", "Clubs", "Coins", "Trumps" ]
  @@tarocchi = [ "Il Matto", "Il Bagatto", "La Papessa", "L'Imperatrice", "L'Imperatore", "Il Papa",
                "Gli Amanti", "Il Carro", "La Giustizia", "L'Ermita", "Rota di Fortuna", "La Forza",
                "L'Appeso", "La Morte", "La Temperenza", "Il Diavolo", "La Torre", "Le Stelle",
                "La Luna", "Il Sole", "L'Angelo", "Il Mondo" ]

  attr_accessor :suit, :number, :name

  def self.suits
    @@suits
  end
  def self.tarocchi
    @@tarocchi
  end

  def self.from_openstruct(data)
    Card.new(data.suit, data.number)
  end

  def self.get_highest_card_of_suit(hand, suit)
    if !hand.find { |c| c.suit == suit }
      return nil
    end

    highest_card = nil
    cards = hand.find_all { |c| c.suit == suit }
    cards.each do |c|
      if !highest_card
        highest_card = c
      else
        if c.is_greater_than(highest_card)
          highest_card = c
        end
      end
    end

    return highest_card
  end

  def self.get_lowest_card_of_suit(hand, suit)
    if !hand.find { |c| c.suit == suit }
      return nil
    end

    lowest_card = nil
    cards = hand.find_all { |c| c.suit == suit }
    cards.each do |c|
      if !lowest_card
        lowest_card = c
      else
        if lowest_card.is_greater_than(c)
          lowest_card = c
        end
      end
    end

    return lowest_card
  end

  def initialize(suit, number)
    @suit = suit
    @number = number
    convert_number_to_integer_if_possible
    generate_name
  end

  def generate_name
    if @suit == "Trumps"
      @name = "#{@@tarocchi[number]} (#{number})"
    elsif @number == 1
      @name = "Ace of #{suit}"
    else
      @name = "#{number} of #{suit}"
    end
  end

  def generate_image_name(type)
    if type == Player.HUMAN
      @name = "#{suit}_#{number}.png"
    else
      @name = "card back black.png"
    end
  end

  def is_greater_than(card)
    if card.number.instance_of?(String) && @number.instance_of?(Integer)
      false
    elsif card.number.instance_of?(Integer) && @number.instance_of?(String)
      true
    elsif card.number.instance_of?(Integer) && @number.instance_of?(Integer)
      if @suit == @@suits[4] 
        if card.number == 21 && @number == 20
          return true
        elsif card.number == 20 && @number == 21
          return false
        else
          @number > card.number
        end
      else
        @number > card.number
      end
    else
      if @number == "Knave"
        false
      elsif @number == "Knight" && card.number != "Knave"
        false
      elsif @number == "Queen" && card.number == "King"
        false
      else
        true
      end
    end
  end

  def is_greater_than_with_suit(card)
    if @suit == card.suit
      return is_greater_than(card)
    else
      return @@suits.find_index(@suit) > @@suits.find_index(card.suit)
    end
  end

  def get_value
    if @suit == @@suits[4]
      if @number == 0
        4
      elsif @number == 1 || @number == 20
        5
      else
        1
      end
    elsif @number == "King"
      5
    elsif @number == "Queen"
      4
    elsif @number == "Knight"
      3
    elsif @number == "Knave"
      2
    else
      1
    end
  end

  def isBagato
    return @suit == @@suits[4] && @number == 1
  end

  def isMatto
    return @suit == @@suits[4] && @number == 0
  end

  def to_s
    if @name == nil
      "nil"
    else
      @name
    end
  end

  def convert_number_to_integer_if_possible()
    if(@number.is_a?(String))
      nums = '0123456789'.split('')

      @number.split('').each do |c|
        if !nums.include?(c)
          return
        end
      end
      @number = @number.to_i
    end
  end
end
