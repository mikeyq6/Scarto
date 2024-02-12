require_relative "../../app/scarto/ai_player_factory"
require_relative "../../app/scarto/ai_player_moderate"
require_relative "../test_helper"

class TestAIPlayerModerate < ActiveSupport::TestCase

    def setup
        @g = Cardgame.new
        @p = Player.new(Player.HUMAN, "Bob")
        @p.ai_level = Player.MODERATE_AI
        @g.add_player(@p)
        # @matto = Card.new(Card.suits[4], 0)
    end

    test "select_card_to_play - play lowest of suit with least cards when leading" do
        c1 = Card.new(Card.suits[3], "Knave")
        c2 = Card.new(Card.suits[0], 10)
        c3 = Card.new(Card.suits[0], 3)
        c4 = Card.new(Card.suits[2], "Queen")
        c5 = Card.new(Card.suits[0], "King")
        c6 = Card.new(Card.suits[4], 15)
        c7 = Card.new(Card.suits[4], 9)
        c8 = Card.new(Card.suits[3], 2)
        c9 = Card.new(Card.suits[3], 7)

        @p.hand = [ c1, c2, c3, c4, c5, c6, c7, c8 ,c9]
        @p.sort_hand
        @g.state.current_trick = []
        ai_player = AIPlayerFactory.get_ai_player(@p)

        assert_equal(c4, ai_player.select_card_to_play(@g), "Should be the lowest card of the first suit")
    end

    test "select_card_to_play - play lowest of suit with least cards when leading, but not trump" do
        c1 = Card.new(Card.suits[3], "Knave")
        c2 = Card.new(Card.suits[3], 10)
        c3 = Card.new(Card.suits[2], 3)
        c4 = Card.new(Card.suits[2], "Queen")
        c7 = Card.new(Card.suits[4], 9)
        c8 = Card.new(Card.suits[3], 2)
        c9 = Card.new(Card.suits[3], 7)

        @p.hand = [ c1, c2, c3, c4, c7, c8, c9]
        @p.sort_hand
        @g.state.current_trick = []
        ai_player = AIPlayerFactory.get_ai_player(@p)

        assert_equal(c3, ai_player.select_card_to_play(@g), "Should be the highest card of the matching suit")
    end

    test "select_card_to_play - play lowest of trump when leading when only have trump cards" do
        c2 = Card.new(Card.suits[4], 10)
        c3 = Card.new(Card.suits[4], 3)
        c7 = Card.new(Card.suits[4], 9)

        @p.hand = [ c2,c3, c7 ]
        @p.sort_hand
        @g.state.current_trick = []
        ai_player = AIPlayerFactory.get_ai_player(@p)

        assert_equal(c3, ai_player.select_card_to_play(@g), "Should be the highest card of the matching suit")
    end
end