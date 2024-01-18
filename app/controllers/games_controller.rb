class GamesController < ApplicationController

    def index
        @games = Game.all
    end

    def show
        # byebug
        @game = Game.find(params[:id])
    # code to grab the proper Post so it can be
    # displayed in the Show view (show.html.erb)
    end

    def new
        @game = Game.new
    end

    def create
        @game = Game.new(params.require(:game).permit(:firstname))
        @game.state = '{}'
        # render plain: @game.inspect
        if @game.save
            redirect_to @game
        else
            render 'new'
        end
    end

    def edit
        @game = Game.find(params[:id])
    end

    def update
        @game = Game.find(params[:id])
        if @game.update(params.require(:game).permit(:firstname))
            redirect_to @game
        else
            render 'edit'
        end
    end

    def destroy
        @game = Game.find(params[:id])
        if @game.delete
            redirect_to games_path
        end 
    end
end
