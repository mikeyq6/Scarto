task :test do
    ruby "test/scarto/test_card.rb"
    ruby "test/scarto/test_player.rb"
    ruby "test/scarto/test_game.rb"
    ruby "test/scarto/test_ai_player_factory.rb"
    ruby "test/scarto/test_ai_player_simple.rb"
    ruby "test/scarto/test_ai_player_moderate.rb"
end