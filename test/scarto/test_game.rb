require_relative "../../app/scarto/game"
require_relative "../test_helper"

class TestGame < ActiveSupport::TestCase

    def setup
        @g = Game.new
    end

    test "deck_created_with_78_cards" do
        assert_equal(78, @g.deck.length, "Wrong number of cards in deck")
    end
    test "computer_players_created" do
        assert_equal(2, @g.players.length, "Should have 2 computer players")
        assert_equal(Player.COMPUTER, @g.players[0].type)
        assert_equal(Player.COMPUTER, @g.players[1].type)
    end

    test "add_player__adds_human_player" do
        @g.add_player("Susan")

        assert_equal(3, @g.players.length, "Should be 3 players now")
        assert_equal(Player.HUMAN, @g.players[2].type)
        assert_equal("Susan", @g.players[2].name)
    end

    test "deal_deck__deals_correct_number_of_cards_to_players_and_stock" do
        @g.add_player("Susan")
        @g.deal_deck

        assert_equal(25, @g.players[0].hand.length)
        assert_equal(25, @g.players[1].hand.length)
        assert_equal(25, @g.players[2].hand.length)
        assert_equal(3, @g.state.stock.length)

        assert_equal(0, @g.deck.length)

        assert_equal("Awaiting dealer swap", @g.state.status)
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