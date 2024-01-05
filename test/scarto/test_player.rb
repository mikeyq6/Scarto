require_relative "../../app/scarto/player"
require_relative "../../app/scarto/card"
require_relative "../test_helper"

class TestPlayer < ActiveSupport::TestCase

    def setup
        @p = Player.new(Player.HUMAN, "Bob")
        @matto = Card.new(Card.suits[4], 0)
    end

    test "has_matto_trick__true_when_matto_trick_present" do
        @p.tricks.push([ @matto ])
        assert(@p.has_matto_trick, "Should be true as matto trick is present")
    end

    test "has_matto_trick__false_when_matto_trick_not_present" do
        assert_not(@p.has_matto_trick, "Should be false as matto trick is not present")
    end

    test "has_matto_trick__false_when_non_matto_card_trick_present" do
        not_matto = Card.new(Card.suits[2], "Queen")
        @p.tricks.push([ not_matto ])
        assert_not(@p.has_matto_trick, "Should be false as matto is not the card in the trick is not present")
    end
end