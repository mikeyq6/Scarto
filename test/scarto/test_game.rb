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
        assert_equal(0, @g.state.stock.length)
        assert_equal(1, @g.state.current_player.tricks.length)
    end

    test "play_card__card_doesnt_exist_in_players_hand__raises_exception" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game

        cp_index = @g.players.find_index(@g.state.current_player)
        op_index = (cp_index + 1) % 3
        card_not_in_players_hand = @g.players[op_index].hand[5]

        assert_raises(GameException) do
            @g.play_card(card_not_in_players_hand)
        end
    end

    test "play_card__play_invalid_card__raises_exception" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game

        suit_card = Card.new(Card.suits[0], 8)
        @g.state.current_trick.push(suit_card)

        player_suit_card = Card.new(Card.suits[0], 4)
        @g.state.current_player.hand[0] = player_suit_card

        invalid_card = Card.new(Card.suits[1], "King")
        
        assert_raises(GameException) do
            @g.play_card(invalid_card)
        end
    end

    test "play_card__card_is_played_successfully__advances_player" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game
        @g.state.first_player = @g.players[1]
        @g.state.current_player = @g.players[1] # set starting player manually

        @g.play_card(@g.state.current_player.hand[0])

        assert_equal(24, @g.players[1].hand.length)
        assert_equal(1, @g.state.current_trick.length)
        assert_equal(@g.players[2].name, @g.state.current_player.name)

        valid_card = Card.new(@g.state.current_trick[0].suit, 2)
        @g.state.current_player.hand[3] = valid_card

        @g.play_card(valid_card)

        assert_equal(24, @g.players[2].hand.length)
        assert_equal(2, @g.state.current_trick.length)
        assert_equal(@g.players[0].name, @g.state.current_player.name)
    end

    test "play_card__matto_is_played__player_gets_trick" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game
        @g.state.first_player = @g.players[1]
        @g.state.current_player = @g.players[1] # set starting player manually
        p1_tricks = @g.players[1].tricks.length

        matto = Card.new(Card.suits[4], 0)
        @g.state.current_player.hand[5] = matto

        @g.play_card(matto)

        assert_equal(p1_tricks + 1, @g.state.first_player.tricks.length)
    end

    test "play_card__last_card_of_hand_played__triggers_end_of_hand" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game

        @g.state.first_player = @g.players[1]
        @g.state.current_player = @g.players[1] # set starting player manually

        valid_card = Card.new(Card.suits[2], 4)
        @g.state.current_player.hand[3] = valid_card
        @g.play_card(valid_card)

        valid_card = Card.new(Card.suits[2], 2)
        @g.state.current_player.hand[3] = valid_card
        @g.play_card(valid_card)

        valid_card = Card.new(Card.suits[2], 3)
        @g.state.current_player.hand[3] = valid_card
        @g.play_card(valid_card)

        assert_equal(0, @g.state.current_trick.length)
    
    end

    test "process_end_of_hand__correct_player_wins_trick" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game

        @g.state.first_player = @g.players[2]
        @g.state.current_player = @g.players[2] # last player to play
        c1 = Card.new(Card.suits[3], 4)
        c2 = Card.new(Card.suits[3], 9)
        c3 = Card.new(Card.suits[3], 2)
        p1_tricks = @g.players[0].tricks.length
        p2_tricks = @g.players[1].tricks.length
        p3_tricks = @g.players[2].tricks.length

        @g.state.current_trick = [ c1, c2, c3 ]
        @g.process_end_of_hand

        assert_equal(p1_tricks + 1, @g.players[0].tricks.length)
        assert_equal(p2_tricks, @g.players[1].tricks.length)
        assert_equal(p3_tricks, @g.players[2].tricks.length)
        assert_equal(0, @g.state.current_trick.length)
        assert_equal(@g.players[0].name, @g.state.current_player.name)
        assert_equal(@g.players[0].name, @g.state.first_player.name)
    end

    test "process_end_of_hand__correct_player_wins_trick_when_matto_played_first" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game

        @g.state.first_player = @g.players[2]
        @g.state.current_player = @g.players[2] 
        matto = Card.new(Card.suits[4], 0)
        c2 = Card.new(Card.suits[3], 9)
        c3 = Card.new(Card.suits[3], 2)
        p1_tricks = @g.players[0].tricks.length
        p2_tricks = @g.players[1].tricks.length
        p3_tricks = @g.players[2].tricks.length

        @g.state.current_player.hand[5] = matto
        @g.play_card(matto)
        @g.state.current_player.hand[2] = c2
        @g.play_card(c2)
        @g.state.current_player.hand[18] = c3
        @g.play_card(c3)

        assert_equal(0, @g.state.current_trick.length)
        assert_equal(p1_tricks + 1, @g.players[0].tricks.length) # extra trick for playing matto
        assert_equal(p2_tricks, @g.players[1].tricks.length)
        assert_equal(p3_tricks + 1, @g.players[2].tricks.length)
        assert_equal(@g.players[0].name, @g.state.current_player.name)
        assert_equal(@g.players[0].name, @g.state.first_player.name)
    end

    test "process_end_of_hand__correct_player_wins_trick_when_matto_played_last" do
        @g.add_player("Susan")
        @g.deal_deck
        @g.start_game

        @g.state.first_player = @g.players[2]
        @g.state.current_player = @g.players[2] 
        matto = Card.new(Card.suits[4], 0)
        c2 = Card.new(Card.suits[3], 9)
        c3 = Card.new(Card.suits[3], 2)
        p1_tricks = @g.players[0].tricks.length
        p2_tricks = @g.players[1].tricks.length
        p3_tricks = @g.players[2].tricks.length

        @g.state.current_player.hand[5] = c2
        @g.play_card(c2)
        @g.state.current_player.hand[2] = c3
        @g.play_card(c3)
        @g.state.current_player.hand[18] = matto
        @g.play_card(matto)

        assert_equal(0, @g.state.current_trick.length)
        assert_equal(p1_tricks, @g.players[0].tricks.length) # extra trick for playing matto
        assert_equal(p2_tricks + 1, @g.players[1].tricks.length)
        assert_equal(p3_tricks + 1, @g.players[2].tricks.length)
        assert_equal(@g.players[2].name, @g.state.current_player.name)
        assert_equal(@g.players[2].name, @g.state.first_player.name)
    end

    test "score_trick__all_single_points_trick" do
        c1 = Card.new(Card.suits[1], 4)
        c2 = Card.new(Card.suits[1], 7)
        c3 = Card.new(Card.suits[1], 1)
        assert_equal(1, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[1], 10)
        c2 = Card.new(Card.suits[3], 2)
        c3 = Card.new(Card.suits[2], 1)
        assert_equal(1, @g.score_trick([c1, c2, c3]))
    end

    test "score_trick__all_court_card_points_trick" do
        c1 = Card.new(Card.suits[1], "King")
        c2 = Card.new(Card.suits[1], "Queen")
        c3 = Card.new(Card.suits[1], "Knight")
        assert_equal(10, @g.score_trick([c1, c2, c3]))

        c2 = Card.new(Card.suits[3], "Knave")
        c3 = Card.new(Card.suits[1], "Knave")
        assert_equal(7, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[1], "Queen")
        c2 = Card.new(Card.suits[2], "Queen")
        c3 = Card.new(Card.suits[3], "Queen")
        assert_equal(10, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[1], "King")
        c2 = Card.new(Card.suits[2], "King")
        c3 = Card.new(Card.suits[3], "King")
        assert_equal(13, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[1], "Knight")
        c2 = Card.new(Card.suits[2], "Knight")
        c3 = Card.new(Card.suits[3], "Knight")
        assert_equal(7, @g.score_trick([c1, c2, c3]))
    end

    test "score_trick__mixed_big_trump_points_trick" do
        c1 = Card.new(Card.suits[1], "King")
        c2 = Card.new(Card.suits[4], 18)
        c3 = Card.new(Card.suits[4], 2)
        assert_equal(5, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[4], 20)
        assert_equal(5, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[4], 21)
        assert_equal(1, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[1], "Queen")
        c2 = Card.new(Card.suits[4], 21)
        c3 = Card.new(Card.suits[4], 20)
        assert_equal(8, @g.score_trick([c1, c2, c3]))

        c2 = Card.new(Card.suits[4], 1)
        assert_equal(12, @g.score_trick([c1, c2, c3]))


        c1 = Card.new(Card.suits[1], "Knave")
        c2 = Card.new(Card.suits[2], 2)
        c3 = Card.new(Card.suits[4], 1)
        assert_equal(6, @g.score_trick([c1, c2, c3]))
    end

    test "score_trick__2_card_trick" do
        c1 = Card.new(Card.suits[1], 4)
        c2 = Card.new(Card.suits[1], 7)
        assert_equal(1, @g.score_trick([c1, c2]))

        c1 = Card.new(Card.suits[1], "King")
        c2 = Card.new(Card.suits[1], 7)
        assert_equal(5, @g.score_trick([c1, c2]))

        c1 = Card.new(Card.suits[1], "King")
        c2 = Card.new(Card.suits[3], "Queen")
        assert_equal(8, @g.score_trick([c1, c2]))

        c1 = Card.new(Card.suits[4], 20)
        c2 = Card.new(Card.suits[3], "Knight")
        assert_equal(7, @g.score_trick([c1, c2]))

        c1 = Card.new(Card.suits[4], 1)
        c2 = Card.new(Card.suits[1], "Knave")
        assert_equal(6, @g.score_trick([c1, c2]))

        c2 = Card.new(Card.suits[4], 20)
        assert_equal(9, @g.score_trick([c1, c2]))
    end

    test "score_trick__matto" do
        matto = Card.new(Card.suits[4], 0)
        assert_equal(4, @g.score_trick([ matto ]))
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

    test "process_game_winner__correct_player_wins__no_other_tricks" do
        @g.add_player("Susan")

        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)
        @g.players[0].tricks.push([c1, c2, c3])

        @g.process_game_winner
        assert_equal(@g.players[0], @g.state.winning_player)
    end

    test "process_game_winner__correct_player_wins__all_players_have_tricks" do
        @g.add_player("Susan")

        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)
        @g.players[0].tricks.push([c1, c2, c3])

        c1 = Card.new(Card.suits[0], "King")
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)
        @g.players[1].tricks.push([c1, c2, c3])

        c1 = Card.new(Card.suits[0], "Knave")
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[4], 20)
        @g.players[2].tricks.push([c1, c2, c3])

        @g.process_game_winner
        assert_equal(@g.players[2], @g.state.winning_player)
    end

    test "process_game_winner__correct_player_wins__tricks_with_matto" do
        @g.add_player("Susan")

        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)
        @g.players[0].tricks.push([c1, c2, c3])

        c1 = Card.new(Card.suits[0], "King")
        c2 = Card.new(Card.suits[1], 1)
        @g.players[1].tricks.push([ c1, c2 ])

        c1 = Card.new(Card.suits[4], 20)
        @g.players[2].tricks.push([ c1 ])

        @g.process_game_winner
        assert_equal(@g.players[1], @g.state.winning_player)
    end
end