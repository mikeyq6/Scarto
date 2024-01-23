# require_relative "../scarto/state"

class PlaygameController < ApplicationController

  def play
    require 'json'

    @gameObj = Game.find(params[:id])

    if @gameObj.status == "New" 
        @game = Cardgame.new
        @game.add_player(@gameObj.firstname)
        @game.deal_deck
        @gameObj.status = "Active"
    else
        @game = Cardgame.from_openstruct(JSON.parse(@gameObj.state, object_class: OpenStruct))
    end


    
    @gameObj.state = @game.to_json
    @gameObj.save
    # byebug

    if @game.state.dealer.type == Player.HUMAN && @game.state.status == 'Awaiting dealer swap'
        render "swap"
    end

    # @game = 

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
    
end

class SwapResult
    attr_accessor :status, :errorMessage
end