class AIPlayerSimple < AIPlayer

  def select_card_to_play(game)
     # Initially just play the first playable card he has
     cardToPlay = nil
     index = 0
    #  player = @game.state.current_player
 
     # byebug
     # Make it slightly smarter, play a low card if leading and a high card if playing
     if game.state.current_trick.size == 0
       while !cardToPlay do
         if game.check_card_is_valid(@player.hand, @player.hand[index], game.state.current_trick)
           cardToPlay = @player.hand[index]
        #    game.play_card(cardToPlay)
        #    additional_cards.push(CardData.new(cardToPlay))
           break
         end
         index = index + 1
       end
     else
       cardToPlay = Card.get_highest_card_of_suit(@player.hand, game.state.current_trick[0].suit)
       
       # if no card of suit, play lowest trump
       if !cardToPlay
         cardToPlay = Card.get_lowest_card_of_suit(@player.hand, Card.suits[4])
       end
 
       # if not trump, play lowest card of remaining suits
       if !cardToPlay
         cardToPlay = Card.get_lowest_card_of_suit(@player.hand, @player.hand.first.suit)
       end
       
    #    game.play_card(cardToPlay)
    #    additional_cards.push(CardData.new(cardToPlay))
     end

     return cardToPlay
   end
end