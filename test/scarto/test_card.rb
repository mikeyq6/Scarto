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
end