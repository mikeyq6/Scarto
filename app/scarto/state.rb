class State
  attr_accessor :status, :current_player, :first_player, :current_trick, :stock, :trick_length, :winning_player

  def self.from_openstruct(data)
    s = State.new
    s.status = data.status
    s.trick_length = data.trick_length
    
    data.current_trick.each do |cardData|
      s.current_trick.push(Card.from_openstruct(cardData))
    end
    data.stock.each do |cardData|
      s.stock.push(Card.from_openstruct(cardData))
    end

    return s
  end

  def initialize
    @status = "Uninitialized"
    @stock = []
    @current_trick = []
    @trick_length = 3
  end
end
