class AIPlayerModerate < AIPlayer

    def select_card_to_play(game)
        cardToPlay = nil
        index = 0
    
        # Make it slightly smarter, play a low card if leading and a high card if playing, unless his card is not high enough to win
        # the trick, in which case play the lowest of the same suit
        if game.state.current_trick.size == 0
            cardToPlay = @player.get_lowest_card_of_suit_with_least_cards_except_trumps
        else
          # Can win trick? If so, play lowest card that beats the current highest
          # otherwise play lowest card of matching suit
          cardToPlay = @player.get_lowest_card_of_suit_higher_than(game.state.current_trick[0])
          # if no high card, then play lowes of matching suit
          if !cardToPlay
            cardToPlay = Card.get_lowest_card_of_suit(@player.hand, game.state.current_trick[0].suit)
          end
          
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