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

    test "sort_hand__sorts_cards_correctly" do
        c1 = Card.new(Card.suits[3], "Knave")
        c2 = Card.new(Card.suits[0], 10)
        c3 = Card.new(Card.suits[0], 3)
        c4 = Card.new(Card.suits[2], "Queen")
        c5 = Card.new(Card.suits[0], "King")
        c6 = Card.new(Card.suits[4], 15)
        c7 = Card.new(Card.suits[4], 9)
        c8 = Card.new(Card.suits[3], 2)
        c9 = Card.new(Card.suits[3], 7)
        c10 = Card.new(Card.suits[4], 20)
        c11 = Card.new(Card.suits[1], "Knave")
        c12 = Card.new(Card.suits[1], "Knight")
        c13 = Card.new(Card.suits[1], 1)

        hand = [ c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13 ]
        expected = [ c3, c2, c5, c13, c11, c12, c4, c8, c9, c1, c7, c6, c10 ]

        @p.hand = hand
        @p.sort_hand

        assert_equal(expected, @p.hand)
    end

    test "sort_hand__empty_hand_sorts_as_empty" do
        @p.hand = []
        @p.sort_hand

        assert_equal([], @p.hand)
    end
end