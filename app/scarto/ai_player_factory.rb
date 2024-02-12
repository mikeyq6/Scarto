require_relative "ai_player"
require_relative "ai_player_simple"
require_relative "ai_player_moderate"

class AIPlayerFactory
    def self.get_ai_player(player)
        ai_player = AIPlayer.new(player)

        case player.ai_level
        when Player.SIMPLE_AI
            ai_player = AIPlayerSimple.new(player)
        when Player.MODERATE_AI
            ai_player = AIPlayerModerate.new(player)
        end

    end
end