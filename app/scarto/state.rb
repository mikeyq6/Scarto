class State
  attr_accessor :status, :current_player, :current_trick, :stock

  def initialize
    @status = "Uninitialized"
    @stock = []
  end
end
