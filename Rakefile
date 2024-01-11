# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task default: %w[test]

task :test do
    ruby "test/scarto/test_card.rb"
    ruby "test/scarto/test_player.rb"
    ruby "test/scarto/test_game.rb"
end