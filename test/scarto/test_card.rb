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
end