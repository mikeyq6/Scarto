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

  def initialize(suit, number)
    @suit = suit
    @number = number
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

  def is_greater_than(card)
    if card.number.instance_of?(String) && @number.instance_of?(Integer)
      false
    elsif card.number.instance_of?(Integer) && @number.instance_of?(String)
      true
    elsif card.number.instance_of?(Integer) && @number.instance_of?(Integer)
      @number > card.number
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

  def to_s
    if @name == nil
      "nil"
    else
      @name
    end
  end
end
