require_relative "../../app/scarto/ai_player_factory"
require_relative "../../app/scarto/ai_player_simple"
require_relative "../../app/scarto/ai_player_moderate"
require_relative "../test_helper"

class TestAIPlayerFactory < ActiveSupport::TestCase

    test "get_ai_player - gets correct class instance" do
        p1 = Player.new(Player.COMPUTER, "PC1")
        p1.ai_level = Player.SIMPLE_AI
        p2 = Player.new(Player.COMPUTER, "PC2")
        p2.ai_level = Player.MODERATE_AI

        psimple = AIPlayerFactory.get_ai_player(p1)
        pmoderate = AIPlayerFactory.get_ai_player(p2)

        assert(psimple.instance_of?(AIPlayerSimple), "Should return a simple AI player instance")
        assert(pmoderate.instance_of?(AIPlayerModerate), "Should return a moderate AI player instance")
    end
end