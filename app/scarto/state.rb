class State
  attr_accessor :status, :current_player, :first_player, :current_trick, :stock, :trick_length

  def initialize
    @status = "Uninitialized"
    @stock = []
    @current_trick = []
    @trick_length = 3
  end
end
