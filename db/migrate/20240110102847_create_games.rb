class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.string :firstname

      t.timestamps
    end
  end
end
