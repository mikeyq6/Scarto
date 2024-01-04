class State
  attr_accessor :status, :current_player, :first_player, :current_trick, :stock

  def initialize
    @status = "Uninitialized"
    @stock = []
    @current_trick = []
  end
end
