require_relative "../../app/scarto/cardgame"
require_relative "../test_helper"

class TestGame < ActiveSupport::TestCase

    def setup
        @g = Cardgame.new
    end

    test "deck created with 78 cards" do
        assert_equal(78, @g.deck.length, "Wrong number of cards in deck")
    end
    
    test "computer players created" do
        assert_equal(2, @g.players.length, "Should have 2 computer players")
        assert_equal(Player.COMPUTER, @g.players[0].type)
        assert_equal(Player.COMPUTER, @g.players[1].type)
    end

    test "add_player - adds human player" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))

        assert_equal(3, @g.players.length, "Should be 3 players now")
        assert_equal(Player.HUMAN, @g.players[2].type)
        assert_equal("Susan", @g.players[2].name)
    end

    test "deal_deck - deals correct number of cards to players and stock" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck

        assert_equal(25, @g.players[0].hand.length)
        assert_equal(25, @g.players[1].hand.length)
        assert_equal(25, @g.players[2].hand.length)
        assert_equal(3, @g.state.stock.length)

        assert_equal(0, @g.deck.length)

        assert_equal("Awaiting dealer swap", @g.state.status)
    end

    test "swap card with stock card - attempt to swap card that isnt in stock - throws exception" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck
        card_not_in_stock = @g.players[0].hand[0]

        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, @g.players[2].hand[0], card_not_in_stock)
        end
    end

    test "swap card with stock card - attempt to swap card that isnt in hand - throws exception" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck
        card_not_in_hand = @g.players[0].hand[0]

        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, card_not_in_hand, @g.state.stock[0])
        end
    end

    test "swap card with stock card - card exists in hand and stock - swap is successful" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck
        card_to_swap = @g.players[2].hand[7]
        stock_card = @g.state.stock[1]

        @g.swap_card_with_stock_card(@g.players[2].hand, card_to_swap, stock_card)
        assert(stock_card.in? @g.players[2].hand)
        assert(card_to_swap.in? @g.state.stock)
        assert_equal(25, @g.players[2].hand.length)
        assert_equal(3, @g.state.stock.length)
    end

    test "swap card with stock card - cannot discard 5-point cards or matto" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck
        king_card = Card.new(Card.suits[2], "King");
        bagato = Card.new(Card.suits[4], 1)
        langelo = Card.new(Card.suits[4], 20)
        matto = Card.new(Card.suits[4], 0)

        @g.players[2].hand[7] = king_card
        @g.players[2].hand[8] = bagato
        @g.players[2].hand[9] = langelo
        @g.players[2].hand[10] = matto
        stock_card = @g.state.stock[1]

        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, king_card, stock_card)
        end
        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, bagato, stock_card)
        end
        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, langelo, stock_card)
        end
        assert_raises(GameException) do
            @g.swap_card_with_stock_card(@g.players[2].hand, matto, stock_card)
        end
        assert(stock_card.in? @g.state.stock)
        assert(king_card.in? @g.players[2].hand)
        assert(bagato.in? @g.players[2].hand)
        assert(langelo.in? @g.players[2].hand)
        assert(matto.in? @g.players[2].hand)
        assert_equal(25, @g.players[2].hand.length)
        assert_equal(3, @g.state.stock.length)
    end

    test "swap card with stock card - can discard bagato if has no other trumps" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck
        bagato = Card.new(Card.suits[4], 1)

        @g.players[2].hand = [ bagato, Card.new(Card.suits[0], 1), Card.new(Card.suits[1], 10), Card.new(Card.suits[3], "Queen") ]
        stock_card = @g.state.stock[1]

        @g.swap_card_with_stock_card(@g.players[2].hand, bagato, stock_card)
 
        assert(stock_card.in? @g.players[2].hand)
        assert(bagato.in? @g.state.stock)
    end

    test "start game - status updated and stock is emptied and given as a trick to the dealer player" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck

        assert_not_nil(@g.state.dealer, "Dealer should be selected")
        assert_not_nil(@g.state.current_player, "Current player should be selected")
        assert_not_nil(@g.state.first_player, "First player should be selected")
        assert_equal(3, @g.state.stock.length)
        assert_equal(0, @g.state.dealer.tricks.length)
        assert_not_equal("Active", @g.state.status, "Status should not be Active")

        @g.start_game

        assert_equal("Active", @g.state.status)
        assert_equal(0, @g.state.stock.length)
        assert_equal(1, @g.state.dealer.tricks.length)
    end

    test "play card - card doesnt exist in players hand - raises exception" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck
        @g.start_game

        cp_index = @g.players.find_index(@g.state.current_player)
        op_index = (cp_index + 1) % 3
        card_not_in_players_hand = @g.players[op_index].hand[5]

        assert_raises(GameException) do
            @g.play_card(card_not_in_players_hand)
        end
    end

    test "play card - play invalid card - raises exception" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
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

    test "play card - card is played successfully - advances player" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
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

    test "play card - matto is played - player gets trick" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
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

    test "play card - last card of hand played - triggers end of hand" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
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

    test "process end of hand - correct player wins trick" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
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

    test "process end of hand - correct player wins trick when matto played first" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
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

    test "process end of hand - correct player wins trick when matto played last" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
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

    test "score trick - all single points trick" do
        c1 = Card.new(Card.suits[1], 4)
        c2 = Card.new(Card.suits[1], 7)
        c3 = Card.new(Card.suits[1], 1)
        assert_equal(1, @g.score_trick([c1, c2, c3]))

        c1 = Card.new(Card.suits[1], 10)
        c2 = Card.new(Card.suits[3], 2)
        c3 = Card.new(Card.suits[2], 1)
        assert_equal(1, @g.score_trick([c1, c2, c3]))
    end

    test "score trick - all court card points trick" do
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

    test "score trick - mixed big trump points trick" do
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

    test "score trick - 2 card trick" do
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

    test "score trick - matto" do
        matto = Card.new(Card.suits[4], 0)
        assert_equal(4, @g.score_trick([ matto ]))
    end

    test "check card is valid - play card of matching suit - return true" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)

        hand = []
        trick = [c1]
        result = @g.check_card_is_valid(hand, c2, trick)

        assert(result)
    end

    test "check card is valid - play card out of suit when hand has no suit - return true" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[2], 2)
        c3 = Card.new(Card.suits[1], 1)

        hand = [c2]
        trick = [c1]
        result = @g.check_card_is_valid(hand, c3, trick)

        assert(result)
    end

    test "check card is valid - play card out of suit when hand has suit - return false" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)

        hand = [c2]
        trick = [c1]
        result = @g.check_card_is_valid(hand, c3, trick)

        assert_not(result)
    end

    test "check card is valid - play matto when hand has suit - return true" do
        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        matto = Card.new(Card.suits[4], 0)

        hand = [c2]
        trick = [c1]
        result = @g.check_card_is_valid(hand, matto, trick)

        assert(result)
    end

    test "process game winner - correct player wins - no other tricks" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))

        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)
        @g.players[0].tricks.push([c1, c2, c3])

        @g.process_game_winner
        assert_equal(@g.players[0], @g.state.winning_player)
    end

    test "process game winner - correct player wins - all players have tricks" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))

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

    test "process game winner - correct player wins - tricks with matto" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))

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

    test "from_openstruct - returns correct game data" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.state.status = "Some status"
        
        gameJson = @g.to_json
        g2 = Cardgame.from_openstruct(JSON.parse(gameJson, object_class: OpenStruct))

        assert_equal(@g.deck.size, g2.deck.size)
        assert_equal(@g.players.size, g2.players.size)
        assert_equal(@g.state.status, g2.state.status)

    end

    test "State.from_openstruct - returns correct state data" do

        c1 = Card.new(Card.suits[0], 1)
        c2 = Card.new(Card.suits[0], 2)
        c3 = Card.new(Card.suits[1], 1)

        @s = State.new
        @s.status = "Some status"
        @s.trick_length = 7
        @s.current_trick = [ c2, c3 ]
        @s.stock = [ c1, c2, c3 ]

        stateJson = @s.to_json
        s2 = State.from_openstruct(JSON.parse(stateJson, object_class: OpenStruct))

        assert_equal(@s.status, s2.status)
        assert_equal(@s.trick_length, s2.trick_length)
        assert_equal(@s.current_trick.size, s2.current_trick.size)
        assert_equal(@s.stock.size, s2.stock.size)
    end

    test "find hand with card - returns correct hand" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck
    
        card_to_find = @g.players[1].hand[6]
        assert_equal(@g.players[1].hand, @g.find_hand_with_card(card_to_find))

        card_to_find = @g.players[2].hand[0]
        assert_equal(@g.players[2].hand, @g.find_hand_with_card(card_to_find))

        card_to_find = @g.players[0].hand[10]
        assert_equal(@g.players[0].hand, @g.find_hand_with_card(card_to_find))
    end

    test "find hand with card - when card exists in no hand - throws exception" do
        @g.add_player(Player.new(Player.HUMAN, "Susan"))
        @g.deal_deck

        playerHand = @g.players[1].hand
        handLength = playerHand.size
        card_to_find = playerHand[6]
        playerHand.delete_at(playerHand.find_index(card_to_find))

        assert_equal(handLength-1, playerHand.size)
        assert_raises(GameException) do
            @g.find_hand_with_card(card_to_find)
        end
    end

    test "when game has a computer dealer - sets status of game to 'Active'" do
        @g.add_player(Player.new(Player.COMPUTER, "Susan"))
        @g.deal_deck

        assert_equal(3, @g.players.size)
        assert_equal("Active", @g.state.status)
    end
end