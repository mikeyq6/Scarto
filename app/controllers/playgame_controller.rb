# require_relative "../scarto/state"

class PlaygameController < ApplicationController

  def play
    require 'json'

    @gameObj = Game.find(params[:id])
# byebug
    if @gameObj.status == "Finished"
      @game = Cardgame.from_openstruct(JSON.parse(@gameObj.state, object_class: OpenStruct))
      render "results"
      return
    elsif @gameObj.status == "New" 
      @game = Cardgame.new
      @game.add_player(Player.new(Player.HUMAN, @gameObj.firstname))
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
    # Initially just play the first playable card he has
    cardToPlay = nil
    index = 0
    player = @game.state.current_player

    # byebug
    # Make it slightly smarter, play a low card if leading and a high card if playing
    if @game.state.current_trick.size == 0
      while !cardToPlay do
        if @game.check_card_is_valid(player.hand, player.hand[index], @game.state.current_trick)
          cardToPlay = player.hand[index]
          @game.play_card(cardToPlay)
          additional_cards.push(CardData.new(cardToPlay))
          break
        end
        index = index + 1
      end
    else
      cardToPlay = Card.get_highest_card_of_suit(player.hand, @game.state.current_trick[0].suit)
      
      # if no card of suit, play lowest trump
      if !cardToPlay
        cardToPlay = Card.get_lowest_card_of_suit(player.hand, Card.suits[4])
      end

      # if not trump, play lowest card of remaining suits
      if !cardToPlay
        cardToPlay = Card.get_lowest_card_of_suit(player.hand, player.hand.first.suit)
      end
      
      @game.play_card(cardToPlay)
      additional_cards.push(CardData.new(cardToPlay))
    end
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