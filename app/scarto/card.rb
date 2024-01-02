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

  def to_s
    @name
  end
end
