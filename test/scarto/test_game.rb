require_relative "../../app/scarto/game"
require_relative "../test_helper"

class TestGame < ActiveSupport::TestCase

    def setup
        @g = Game.new
    end

    test "deck_created_with_78_cards" do
        assert_equal(78, @g.deck.length, "Wrong number of cards in deck")
    end

end