class GamesController < ApplicationController
    before_action :set_game, only: [:show, :destroy, :edit, :update]


    def index
        @games = Game.all
    end

    def show
    
    end

    def new
        @game = Game.new
    end

    def create
        @game = Game.new(params.require(:game).permit(:firstname))
        @game.state = '{}'
        @game.status = 'New'
        # render plain: @game.inspect
        if @game.save
            redirect_to @game
        else
            render 'new'
        end
    end

    def edit

    end

    def update

        if @game.update(params.require(:game).permit(:firstname))
            redirect_to @game
        else
            render 'edit'
        end
    end

    def destroy
        if @game.delete
            redirect_to games_path
        end 
    end

    private
    def set_game
        @game = Game.find(params[:id])
    end
end
