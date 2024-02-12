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
        player_name = params.require(:game).permit(:firstname)
        @game = Game.new(player_name)
        @game.state = '{}'
        @game.status = 'New'

        # render plain: @game.inspect
        if @game.save
            create_players(@game.firstname)
            @game.save
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

    def create_players(player_name)
        pc1 = @game.game_players.create
        pc1.player_type = Player.COMPUTER
        pc1.name = "PC1"
        pc1.ai_level = Player.SIMPLE_AI
        pc2 = @game.game_players.create
        pc2.player_type = Player.COMPUTER
        pc2.name = "PC2"
        pc2.ai_level = Player.SIMPLE_AI
        hp = @game.game_players.create
        hp.player_type = Player.HUMAN
        hp.name = player_name
        hp.ai_level = Player.SIMPLE_AI

        @game.game_players = [ pc1, pc2, hp ]
    end
end
