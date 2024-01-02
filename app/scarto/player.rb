class Player
  attr_accessor :name, :cards, :tricks
  attr_reader :id

  def initialize
    @tricks = []
  end
end
