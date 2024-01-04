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

    test "swap_card_with_stock_card__attempt_to_swap_card_that_isnt_in_stock__throws_exception" do
        @g.add_player("Susan")
        @g.deal_deck
        card_not_in_stock = @g.players[0].hand[0]

        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, @g.players[2].hand[0], card_not_in_stock)
        end
    end

    test "swap_card_with_stock_card__attempt_to_swap_card_that_isnt_in_hand__throws_exception" do
        @g.add_player("Susan")
        @g.deal_deck
        card_not_in_hand = @g.players[0].hand[0]

        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, card_not_in_hand, @g.state.stock[0])
        end
    end

    test "swap_card_with_stock_card__card_exists_in_hand_and_stock__swap_is_successful" do
        @g.add_player("Susan")
        @g.deal_deck
        card_to_swap = @g.players[2].hand[7]
        stock_card = @g.state.stock[1]

        @g.swap_card_with_stock_card(@g.players[2].hand, card_to_swap, stock_card)
        assert(stock_card.in? @g.players[2].hand)
        assert(card_to_swap.in? @g.state.stock)
        assert_equal(25, @g.players[2].hand.length)
        assert_equal(3, @g.state.stock.length)
    end

    test "start_game__status_updated_and_starting_player_is_selected" do
        @g.add_player("Susan")
        @g.deal_deck

        assert_nil(@g.state.current_player, "No current player should be selected")
        assert_not_equal("Active", @g.state.status, "Status should not be Active")

        @g.start_game

        assert_not_nil(@g.state.current_player, "Current player should be selected")
        assert_equal("Active", @g.state.status)

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