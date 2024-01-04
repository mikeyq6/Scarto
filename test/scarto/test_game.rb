require_relative "../../app/scarto/game"
require_relative "../test_helper"

class TestGame < ActiveSupport::TestCase

    def setup
        @g = Game.new
    end

    test "deck_created_with_78_cards" do
        assert_equal(78, @g.deck.length, "Wrong number of cards in deck")
    end

    test "check_card_is_valid__play_card_of_matching_suit__return_true" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)

        hand = []
        trick = [c1]
        result = @g.check_card_is_valid(hand, c2, trick)

        assert(result)
    end

    test "check_card_is_valid__play_card_out_of_suit_when_hand_has_no_suit__return_true" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[2], 2)
        c3 = Card.new(Card.suits[1], 1)

        hand = [c2]
        trick = [c1]
        result = @g.check_card_is_valid(hand, c3, trick)

        assert(result)
    end

    test "check_card_is_valid__play_card_out_of_suit_when_hand_has_suit__return_false" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)

        hand = [c2]
        trick = [c1]
        result = @g.check_card_is_valid(hand, c3, trick)

        assert_not(result)
    end

    test "check_card_is_valid__play_matto_when_hand_has_suit__return_true" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        matto = Card.new(Card.suits[4], 0)

        hand = [c2]
        trick = [c1]
        result = @g.check_card_is_valid(hand, matto, trick)

        assert(result)
    end

end