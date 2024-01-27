require_relative "state"
require_relative "player"
require_relative "card"

class Cardgame
  attr_accessor :players, :deck, :state
  attr_reader :id
  @rnd

  def self.from_openstruct(data)
    cardgame = Cardgame.new
    cardgame.players = []
    cardgame.deck = []

    data.players.each do |playerData|
      cardgame.players.push(Player.from_openstruct(playerData))
    end
    data.deck.each do |cardData|
      cardgame.deck.push(Card.from_openstruct(cardData))
    end
    cardgame.state = State.from_openstruct(data.state)

    # byebug

    return cardgame
  end

  def initialize
    @state = State.new
    @players = []
    @deck = []
    @rnd = Random.new

    create_deck
    shuffle_deck
    add_computer_players

    @state.status = 'Initialized'
  end

  def add_computer_players
    @players.push(
      Player.new(Player.COMPUTER, "PC1")
    )
    @players.push(
      Player.new(Player.COMPUTER, "PC2")
    )
  end

  def set_dealer
    # byebug
    if @players.size == 3
      dealerIndex = @rnd.rand(@players.size)
      @state.dealer = @players[dealerIndex]
      @state.first_player = @players[(dealerIndex + 1) % @players.size]
      @state.current_player = @state.first_player
    end
  end

  def add_player(player)
    @players.push(
      player
    )
    set_dealer
  end

  def create_deck
    Card.suits.each do |suit|

      if suit == "Trumps"
        (0..21).each do |num|
          deck.push(
            Card.new(suit, num)
          )
        end
      else
        [1,2,3,4,5,6,7,8,9,10, "Knave", "Knight", "Queen", "King"].each do |num|
          deck.push(
            Card.new(suit, num)
          )
        end
      end
    end
  end

  def shuffle_deck
    len = deck.length

    for index in 0..(len-1)
      next_num = @rnd.rand(len - index)
      deck.push(deck[next_num])
      deck.delete_at(next_num)
    end
    deck.push(deck[0])
    deck.delete_at(0)
  end

  def deal_deck
    for index in 0..(@deck.length-4)
      @players[index % 3].hand.push(@deck[index])
    end
    for index in (@deck.length-3)..(@deck.length-1)
      @state.stock.push(@deck[index])
    end
    @deck = []
    @state.status = "Awaiting dealer swap"

    @players.each do |player|
      player.sort_hand
    end

    if @state.dealer.type == Player.COMPUTER
      @state.status = "Active"
    end
  end

  def start_game
    @state.status = "Active"
    @state.dealer.tricks.push(@state.stock)
    @state.stock = []
  end

  def play_card(card)
    player_hand = @state.current_player.hand
    # byebug

    if !player_hand.find { |c| c.suit == card.suit && c.number == card.number }
      raise GameException.new "Attempt to play a card not in the current player's hand"
    elsif !check_card_is_valid(player_hand, card, @state.current_trick)
      raise GameException.new "Attempt to play an invalid card"
    else
      player_hand.delete_at(get_card_index(player_hand, card))

      if card.suit == Card.suits[4] && card.number == 0
        @state.trick_length = 2
        @state.current_player.tricks.push([ card ])
      else
        @state.current_trick.push(card)
      end

      if(@state.current_trick.length == @state.trick_length)
        process_end_of_hand
      else
        advance_player
      end

      if @state.current_player.hand.length == 0
        @g.state.status = "Finished"
        process_game_winner
      end
    end
  end

  def advance_player
    cp_index = get_player_index(@state.current_player)
    cp_index = (cp_index + 1) % 3
    @state.current_player = @players[cp_index]
  end

  def process_end_of_hand
    winner = process_hand_winner
    winner.tricks.push(@state.current_trick)

    @state.current_trick = []
    @state.first_player = winner
    @state.current_player = winner
    @state.trick_length = 3
  end

  def process_hand_winner
    trick = @state.current_trick
    has_big_trump = trick.find { |card| card.suit == Card.suits[4] }

    if !has_big_trump # find largest matching first card played suit
      highest_card = trick[0]

      if trick[1].suit == highest_card.suit && trick[1].is_greater_than(highest_card)
        highest_card = trick[1]
      end
      if(@state.trick_length == 3)
        if trick[2].suit == highest_card.suit && trick[2].is_greater_than(highest_card)
          highest_card = trick[2]
        end
      end
    else
      if trick[0].suit == Card.suits[4]
        highest_card = trick[0]
      end
      if trick[1].suit == Card.suits[4]
        if highest_card == nil
          highest_card = trick[1]
        elsif trick[1].is_greater_than(highest_card)
          highest_card = trick[1]
        end
      end
      if trick[2].suit == Card.suits[4]
        if highest_card == nil
          highest_card = trick[2]
        elsif trick[2].is_greater_than(highest_card)
          highest_card = trick[2]
        end
      end
    end

    highest_card_index = get_card_index(trick, highest_card) #trick.find_index(highest_card)
    winning_player_index = (get_player_index(@state.first_player) + highest_card_index) % 3

    if @players[winning_player_index].has_matto_trick
      winning_player_index = (winning_player_index + 1) % 3
    end

    @players[winning_player_index]

  end

  def process_game_winner
    @players.each do |p|
      score = 0
      p.tricks.each do |trick|
        score += score_trick trick
      end
      p.score = score

      if !@state.winning_player || score > @state.winning_player.score
        @state.winning_player = p
      end
    end
  end

  def score_trick(trick)
    if trick.length == 1
      return trick[0].get_value
    elsif trick.length == 2
      return (trick[0].get_value + trick[1].get_value + 1) - 2
    else
      return (trick[0].get_value + trick[1].get_value + trick[2].get_value) - 2
    end
  end

  def swap_card_with_stock_card(hand, card, stock_card) 
    if !hand.find { |c| c.suit == card.suit && c.number == card.number }
      raise GameException.new "Attempt to swap card not in player hand"
    elsif !@state.stock.find { |c| c.suit == stock_card.suit && c.number == stock_card.number }
      raise GameException.new "Attempt to swap card with card not in stock"
    else
      if card.get_value == 5 || card.isMatto
        if !card.isBagato || hand.find { |c| c.suit == Card.suits[4] && c.number != 1}
          raise GameException.new "Cannot swap out Kings, The Matto or the The Bagato cards"
        end
      end
      card_index = get_card_index(hand, card) #hand.find_index(hand.find { |c| c.suit == card.suit && c.number == card.number})
      stock_card_index = get_card_index(@state.stock, stock_card) # @state.stock.find_index(@state.stock.find { |c| c.suit == stock_card.suit && c.number == stock_card.number})
      temp = hand[card_index]
      hand[card_index] = stock_card
      @state.stock[stock_card_index] = card
    end
  end

  def check_card_is_valid(hand, card, trick)
    if card.isMatto
      true
    elsif trick.length > 0
      if card.suit == trick[0].suit
        true
      elsif !hand_contains_suit(hand, trick[0].suit)
        true
      else
        false
      end
    else
      true
    end 
  end

  def hand_contains_suit(hand, target_suit) 
    hand.each do |card|
      if card.suit == target_suit
        return true
      end
    end
    return false
  end

  def find_hand_with_card(card) 
    @players.each do |player|
      if player.hand.find { |c| c.suit == card.suit && c.number == card.number }
        return player.hand
      end
    end
    raise GameException.new "Card not found in any player hand"
  end

  def display_deck
    @deck.each do |card|
      puts "#{card}"
    end
  end

  def to_json(options={})
     options[:except] ||= [:rnd]
     super(options)
  end

  private 
  def get_player_index(player)
    # byebug
    return @players.find_index(@players.find { |p| p.name == player.name })
  end

  private 
  def get_card_index(hand, card)
    return hand.find_index(hand.find { |c| c.suit == card.suit  && c.number == card.number})
  end

end
