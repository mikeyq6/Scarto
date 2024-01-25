# require_relative "../scarto/state"

class PlaygameController < ApplicationController

  def play
    require 'json'

    @gameObj = Game.find(params[:id])

    if @gameObj.status == "New" 
        @game = Cardgame.new
        @game.add_player(Player.new(Player.HUMAN, @gameObj.firstname))
        @game.deal_deck
        @gameObj.status = "Active"
    else
        @game = Cardgame.from_openstruct(JSON.parse(@gameObj.state, object_class: OpenStruct))
    end


    while @game.state.current_player.type == Player.COMPUTER do
      ai_player_play
    end
    
    @gameObj.state = @game.to_json
    @gameObj.save

    if @game.state.dealer.type == Player.HUMAN && @game.state.status == 'Awaiting dealer swap'
        render "swap"
    end


    # byebug
    
  end

  def swap
    get_game

    sourceCard = Card.new(params[:scSuit], params[:scNumber])
    stockCard = Card.new(params[:tcSuit], params[:tcNumber])

    result = SwapResult.new

    begin
        hand = @game.find_hand_with_card(sourceCard)
        player = @game.players.find { |player| player.hand == hand }

        @game.swap_card_with_stock_card(hand, sourceCard, stockCard)
        player.sort_hand

        save_game

        result.status = 'ok'
    rescue GameException => e
        result.status = 'error'
        result.errorMessage = e.message
    end

    render json: result

    return result
  end

  def swap_done
    get_game
    @game.start_game
    save_game
  end

  def get_game
    @gameObj = Game.find(params[:id])
    @game = Cardgame.from_openstruct(JSON.parse(@gameObj.state, object_class: OpenStruct))
  end

  def save_game
    @gameObj.state = @game.to_json
    @gameObj.save
  end
    
  private
  def ai_player_play
    # Initially just play the first playable card he has
    cardToPlay = nil
    index = 0
    player = @game.state.current_player

    byebug
    while !cardToPlay do
      if @game.check_card_is_valid(player.hand, player.hand[index], @game.state.current_trick)
        cardToPlay = player.hand[index]
        @game.play_card(cardToPlay)
      end
      index = index + 1
    end
  end
end

class SwapResult
    attr_accessor :status, :errorMessage
end