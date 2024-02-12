class AIPlayer
    
  def initialize(player)
    @player = player
  end

  def select_card_to_play(game)
    # Just play the first playable card he has
    cardToPlay = nil
    index = 0

    @player.hand.each do |card|
      if game.check_card_is_valid(@player.hand, @player.hand[index], game.state.current_trick)
        cardToPlay = @player.hand[index]
        break
      end
      index = index + 1
    end

    return cardToPlay
  end
end