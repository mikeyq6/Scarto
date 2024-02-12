class AIPlayerSimple < AIPlayer

  def select_card_to_play(game)
     cardToPlay = nil
     index = 0

     # Make it slightly smarter, play a low card if leading and a high card if playing
     if game.state.current_trick.size == 0
       while !cardToPlay do
         if game.check_card_is_valid(@player.hand, @player.hand[index], game.state.current_trick)
           cardToPlay = @player.hand[index]
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
       
     end

     return cardToPlay
   end
end