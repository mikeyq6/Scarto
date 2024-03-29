require_relative "../../app/scarto/card"
require_relative "../test_helper"

class TestCard < ActiveSupport::TestCase
    test "is_greater_than__2_numeric" do
        c1 = Card.new(Card.suits[0], 2)
        c2 = Card.new(Card.suits[0], 4)

        assert(c2.is_greater_than(c1), "4 should be greater than 2")
        assert(!c1.is_greater_than(c2), "2 should not be greater than 4")
    end

    test "is_greater_than__2_court_cards" do
        c1 = Card.new(Card.suits[0], "King")
        c2 = Card.new(Card.suits[0], "Queen")

        assert(c1.is_greater_than(c2), "King is bigger than Queen")
        assert(!c2.is_greater_than(c1), "Queen is smaller than King")
        
        c1.number = "Knave"
        assert(!c1.is_greater_than(c2), "Knave is smaller than Queen")
        assert(c2.is_greater_than(c1), "Queen is bigger than Knave")

        c1.number = "Knight"
        c2.number = "King"
        assert(!c1.is_greater_than(c2), "Knight is smaller than King")
        assert(c2.is_greater_than(c1), "King is bigger than Knight")
    end

    test "is_greater_than__mixed_cards" do
        c1 = Card.new(Card.suits[0], 10)
        c2 = Card.new(Card.suits[0], "Queen")

        assert(!c1.is_greater_than(c2), "10 is smaller than Queen")
        assert(c2.is_greater_than(c1), "Queen is bigger than 10")
        
        c1.number = "Knave"
        c2.number = 1
        assert(c1.is_greater_than(c2), "Knave is bigger than Ace")
        assert(!c2.is_greater_than(c1), "Ace is smaller than Knave")
    end

    test "is_greater_than - test 21 vs 20 trump cards" do
        c1 = Card.new(Card.suits[4], 21)
        c2 = Card.new(Card.suits[4], 20)

        assert(!c1.is_greater_than(c2), "21 should not be higher than 20 in trumps")
        assert(c2.is_greater_than(c1), "20 should be higher than 21 in trumps")
    end

    test "is_greater_than_with_suit__same_suit_uses_number" do
        c1 = Card.new(Card.suits[0], 10)
        c2 = Card.new(Card.suits[0], "Queen")

        assert(!c1.is_greater_than_with_suit(c2), "10 is smaller than Queen")
        assert(c2.is_greater_than_with_suit(c1), "Queen is bigger than 10")
        
        c1.number = "Knave"
        c2.number = 1
        assert(c1.is_greater_than_with_suit(c2), "Knave is bigger than Ace")
        assert(!c2.is_greater_than_with_suit(c1), "Ace is smaller than Knave")
    end

    test "is_greater_than_with_suit__different_suits_sort_by_suit" do
        c1 = Card.new(Card.suits[1], 10)
        c2 = Card.new(Card.suits[0], "Queen")

        assert(c1.is_greater_than_with_suit(c2), "#{c1.suit} is greater than #{c2.suit}")
        assert(!c2.is_greater_than_with_suit(c1), "#{c2.suit} is not greater than #{c1.suit}")

        c2.suit = Card.suits[4]

        assert(!c1.is_greater_than_with_suit(c2), "#{c1.suit} is not greater than #{c2.suit}")
        assert(c2.is_greater_than_with_suit(c1), "#{c2.suit} is greater than #{c1.suit}")

    end

    test "get_value" do
        c1 = Card.new(Card.suits[0], 1)
        assert_equal(1, c1.get_value)
        c1 = Card.new(Card.suits[0], 10)
        assert_equal(1, c1.get_value)
        c1 = Card.new(Card.suits[0], "Knave")
        assert_equal(2, c1.get_value)
        c1 = Card.new(Card.suits[0], "Knight")
        assert_equal(3, c1.get_value)
        c1 = Card.new(Card.suits[0], "Queen")
        assert_equal(4, c1.get_value)
        c1 = Card.new(Card.suits[0], "King")
        assert_equal(5, c1.get_value)
        c1 = Card.new(Card.suits[4], 0) # matto
        assert_equal(4, c1.get_value)
        c1 = Card.new(Card.suits[4], 20) 
        assert_equal(5, c1.get_value)
        c1 = Card.new(Card.suits[4], 1) 
        assert_equal(5, c1.get_value)
        c1 = Card.new(Card.suits[4], 12) 
        assert_equal(1, c1.get_value)
        c1 = Card.new(Card.suits[4], 21) 
        assert_equal(1, c1.get_value)
        c1 = Card.new(Card.suits[4], 2) 
        assert_equal(1, c1.get_value)
        c1 = Card.new(Card.suits[4], 13) 
        assert_equal(1, c1.get_value)

    end

    test "from_openstruct__returns_correct_card_data" do
        c1 = Card.new(Card.suits[0], "King")

        cardJson = c1.to_json
        c2 = Card.from_openstruct(JSON.parse(cardJson, object_class: OpenStruct))

        assert_equal(c1.number, c2.number)
        assert_equal(c1.suit, c2.suit)
        assert_equal(c1.name, c2.name)
    end

    test "convert_to_number_if_possible - works for numbers" do
        c1 = Card.new(Card.suits[0], "King")
        c2 = Card.new(Card.suits[2], "3")
        c3 = Card.new(Card.suits[4], "13")
        c4 = Card.new(Card.suits[2], 4)
        c5 = Card.new(Card.suits[1], "10")
        c6 = Card.new(Card.suits[1], "Knave")

        assert_equal("King", c1.number)
        assert_equal(3, c2.number)
        assert_equal(13, c3.number)
        assert_equal(4, c4.number)
        assert_equal(10, c5.number)
        assert_equal("Knave", c6.number)
    end

    test "get_highest_card_of_suit - returns correct card" do
        c1 = Card.new(Card.suits[0], "Queen")
        c2 = Card.new(Card.suits[2], 3)
        c3 = Card.new(Card.suits[4], 13)
        c4 = Card.new(Card.suits[2], 4)
        c5 = Card.new(Card.suits[1], 10)
        c6 = Card.new(Card.suits[1], "Knave")
        c7 = Card.new(Card.suits[0], 7)
        c8 = Card.new(Card.suits[0], "King")
        c9 = Card.new(Card.suits[4], 21)
        c10 = Card.new(Card.suits[4], 20)
        c11 = Card.new(Card.suits[3], 1)

        hand = [ c1, c2, c3 ,c4 ,c5, c6, c7, c8, c9, c10, c11 ]

        assert_equal(c8, Card.get_highest_card_of_suit(hand, Card.suits[0]))
        assert_equal(c6, Card.get_highest_card_of_suit(hand, Card.suits[1]))
        assert_equal(c4, Card.get_highest_card_of_suit(hand, Card.suits[2]))
        assert_equal(c11, Card.get_highest_card_of_suit(hand, Card.suits[3]))
        assert_equal(c10, Card.get_highest_card_of_suit(hand, Card.suits[4]))
    end

    test "get_highest_card_of_suit - no matching card of that suit, returns nil" do
        c1 = Card.new(Card.suits[0], "Queen")
        c2 = Card.new(Card.suits[2], 3)
        c3 = Card.new(Card.suits[4], 13)

        hand = [ c1, c2, c3 ]

        assert_nil(Card.get_highest_card_of_suit(hand, Card.suits[3]))
    end

    test "get_lowest_card_of_suit - returns correct card" do
        c1 = Card.new(Card.suits[0], "Queen")
        c2 = Card.new(Card.suits[2], 3)
        c3 = Card.new(Card.suits[4], 13)
        c4 = Card.new(Card.suits[2], 4)
        c5 = Card.new(Card.suits[1], 10)
        c6 = Card.new(Card.suits[1], "Knave")
        c7 = Card.new(Card.suits[0], 7)
        c8 = Card.new(Card.suits[0], "King")
        c9 = Card.new(Card.suits[4], 21)
        c10 = Card.new(Card.suits[4], 20)
        c11 = Card.new(Card.suits[3], 1)

        hand = [ c1, c2, c3 ,c4 ,c5, c6, c7, c8, c9, c10, c11 ]

        assert_equal(c7, Card.get_lowest_card_of_suit(hand, Card.suits[0]))
        assert_equal(c5, Card.get_lowest_card_of_suit(hand, Card.suits[1]))
        assert_equal(c2, Card.get_lowest_card_of_suit(hand, Card.suits[2]))
        assert_equal(c11, Card.get_lowest_card_of_suit(hand, Card.suits[3]))
        assert_equal(c3, Card.get_lowest_card_of_suit(hand, Card.suits[4]))
    end

    test "get_lowest_card_of_suit - no matching card of that suit, returns nil" do
        c1 = Card.new(Card.suits[0], "Queen")
        c2 = Card.new(Card.suits[2], 3)
        c3 = Card.new(Card.suits[4], 13)

        hand = [ c1, c2, c3 ]

        assert_nil(Card.get_lowest_card_of_suit(hand, Card.suits[3]))
    end
end