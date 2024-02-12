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

    test "from_openstruct__returns_correct_player_data" do
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

        @p.hand = [ c1, c2, c3, c4 ]
        @p.tricks = [ [ c5, c6, c7 ], [ c8, c9, c10 ], [ c11, c12, c13] ]
        @p.score = 22

        playerJson = @p.to_json
        p2 = Player.from_openstruct(JSON.parse(playerJson, object_class: OpenStruct))

        assert_equal(@p.name, p2.name)
        assert_equal(@p.type, p2.type)
        assert_equal(@p.score, p2.score)
        assert_equal(@p.tricks.size, p2.tricks.size)
        assert_equal(@p.hand.size, p2.hand.size)
    end

    test "get_lowest_card_of_suit_with_least_cards_except_trumps - with empty hand - returns nil" do
        @p.hand = []

        assert_nil(@p.get_lowest_card_of_suit_with_least_cards_except_trumps, "Should return nil if nothing found")
    end

    test "get_lowest_card_of_suit_with_least_cards_except_trumps - with cards where trumps are the lowest number of cards - returns non-trump card" do
        c1 = Card.new(Card.suits[3], "Knave")
        c2 = Card.new(Card.suits[0], 10)
        c3 = Card.new(Card.suits[0], 3)
        c5 = Card.new(Card.suits[0], "King")
        c6 = Card.new(Card.suits[4], 15)
        c8 = Card.new(Card.suits[3], 2)
        
        @p.hand = [c1, c2, c3, c5, c6, c8]
        @p.sort_hand

        assert_equal(c8, @p.get_lowest_card_of_suit_with_least_cards_except_trumps, "Should return suit 0 lowest")
    end

    test "get_lowest_card_of_suit_with_least_cards_except_trumps - with only trumps - returns lowest trump" do
        c2 = Card.new(Card.suits[4], 10)
        c3 = Card.new(Card.suits[4], 3)
        c6 = Card.new(Card.suits[4], 15)
        c8 = Card.new(Card.suits[4], 2)
        c9 = Card.new(Card.suits[4], 7)
        
        @p.hand = [c2, c3, c6, c8, c9]
        @p.sort_hand

        assert_equal(c8, @p.get_lowest_card_of_suit_with_least_cards_except_trumps, "Should return suit lowest trump")
    end

    test "get_lowest_card_of_suit_higher_than - empty hand - returns nil" do
        c1 = Card.new(Card.suits[3], "Knave")
        @p.hand = []

        assert_nil(@p.get_lowest_card_of_suit_higher_than(c1), "No matching card so should return nil")
    end

    test "get_lowest_card_of_suit_higher_than - has no matching cards of suit - returns nil" do
        c1 = Card.new(Card.suits[3], "Knave")
        c2 = Card.new(Card.suits[0], 10)
        c3 = Card.new(Card.suits[0], 3)
        c4 = Card.new(Card.suits[2], "Queen")
        c5 = Card.new(Card.suits[0], "King")
        c6 = Card.new(Card.suits[4], 15)

        @p.hand = [ c1, c2, c3, c5, c6 ]

        assert_nil(@p.get_lowest_card_of_suit_higher_than(c4), "No matching card so should return nil")
    end

    test "get_lowest_card_of_suit_higher_than - has no card that beats target - returns nil" do
        c1 = Card.new(Card.suits[3], "Knave")
        c2 = Card.new(Card.suits[2], 10)
        c3 = Card.new(Card.suits[2], 3)
        c4 = Card.new(Card.suits[2], "Queen")
        c5 = Card.new(Card.suits[0], "King")
        c6 = Card.new(Card.suits[4], 15)

        @p.hand = [ c1, c2, c3, c5, c6 ]

        assert_nil(@p.get_lowest_card_of_suit_higher_than(c4), "No matching card so should return nil")
    end

    test "get_lowest_card_of_suit_higher_than - has multiple matching cards of suit - returns lowest that is higher than target" do
        c1 = Card.new(Card.suits[2], "Knave")
        c2 = Card.new(Card.suits[2], 10)
        c3 = Card.new(Card.suits[2], 3)
        c4 = Card.new(Card.suits[2], "Queen")
        c5 = Card.new(Card.suits[2], "King")
        c6 = Card.new(Card.suits[4], 15)

        @p.hand = [ c1, c3, c4, c5, c6 ]

        assert_equal(c1, @p.get_lowest_card_of_suit_higher_than(c2), "matching card, should be lowest of same suit higher than #{c1.name}")
    end
end