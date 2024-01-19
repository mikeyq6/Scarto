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

    # @game = 

 end
    
end