# require_relative "../scarto/state"
require_relative "../scarto/ai_player_factory"

class PlaygameController < ApplicationController

  def play
    require 'json'

    @gameObj = Game.find(params[:id])

    if @gameObj.status == "Finished"
      @game = Cardgame.from_openstruct(JSON.parse(@gameObj.state, object_class: OpenStruct))
      render "results"
      return
    elsif @gameObj.status == "New" 
      @game = Cardgame.new
# byebug
      @gameObj.game_players.each do |gp|
        @game.add_player(Player.new(gp.player_type.to_i, gp.name))
      end

      @game.deal_deck
      @gameObj.status = "Active"
      if(@game.state.dealer.type == Player.COMPUTER)
        @game.start_game
      end
    else
      @game = Cardgame.from_openstruct(JSON.parse(@gameObj.state, object_class: OpenStruct))
    end

    if @game.state.status == "Finished"
      @gameObj.status = "Finished"
      save_game
      render "results"
      return
    end

    while @game.state.current_player.type == Player.COMPUTER do
      ai_player_play([])
    end
    
    save_game

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

  def play_card
    get_game
    card = Card.new(params[:cardSuit], params[:cardNumber])

    result = PlayResult.new
# byebug
    begin
      @game.play_card(card)
      # hand = @game.find_hand_with_card(sourceCard)
      # player = @game.players.find { |player| player.hand == hand }

      # @game.swap_card_with_stock_card(hand, sourceCard, stockCard)
      # player.sort_hand

      # save_game
      # have any ai players finish their turns
      additional_cards = []
      # if @game.state.current_trick.length < @game.state.trick_length
      while @game.state.current_trick.length > 0 && @game.state.current_trick.length < @game.state.trick_length && @game.state.status != "Finished" && @game.state.current_player.type == Player.COMPUTER do
        ai_player_play(additional_cards)
# byebug

        # additional_cards.push(@game.state.current_trick.last.to_json)
      end
      # end

      result.hasAdditionalCards = additional_cards.size > 0
      result.additionalCardJson = additional_cards.to_json
      result.status = 'ok'

      if @game.state.status == "Finished"
        @gameObj.status = "Finished"
      end
      result.stateJson = @game.to_json

      save_game
    rescue GameException => e
      result.status = 'error'
      result.errorMessage = e.message
    end

    render json: result

    # return result
    # byebug
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
  def ai_player_play(additional_cards)
    player = @game.state.current_player
    ai_player = AIPlayerFactory.get_ai_player(player)
    cardToPlay = ai_player.select_card_to_play(@game)
      
    @game.play_card(cardToPlay)
    additional_cards.push(CardData.new(cardToPlay))
  end
end

class SwapResult
    attr_accessor :status, :errorMessage
end

class PlayResult < SwapResult
  attr_accessor :additionalCardJson, :hasAdditionalCards, :stateJson
end

class CardData
  attr_accessor :name, :number, :suit, :imgName

  def initialize(card)
    @name = card.name
    @number = card.number
    @suit = card.suit
    @imgName = card.generate_image_name(Player.HUMAN)
  end
end