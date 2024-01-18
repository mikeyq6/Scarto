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
        @game = JSON.parse(@gameObj.state, object_class: Cardgame)
        byebug
    end
    
    @gameObj.state = @game.to_json
    @gameObj.update(params.permit(:state, :status))
    # byebug

    # @game = 

 end
    
end