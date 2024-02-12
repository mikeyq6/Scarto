class AddPlayer < ActiveRecord::Migration[6.1]
  def change
    create_table :game_players do |t|
      t.belongs_to :game, index: true
      t.string :name
      t.numeric :player_type
      t.numeric :ai_level
    end
  end
end
