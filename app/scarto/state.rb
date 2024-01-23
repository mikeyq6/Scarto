class State
  attr_accessor :status, :dealer, :current_player, :first_player, :current_trick, :stock, :trick_length, :winning_player

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
    if data.dealer
      s.dealer = Player.from_openstruct(data.dealer)
    end
    if data.current_player
      s.current_player = Player.from_openstruct(data.current_player)
    end
    if data.first_player
      s.first_player = Player.from_openstruct(data.first_player)
    end

    return s
  end

  def initialize
    @status = "Uninitialized"
    @stock = []
    @current_trick = []
    @trick_length = 3
    @current_player = nil
    @first_player = nil
    @dealer = nil
  end
end
