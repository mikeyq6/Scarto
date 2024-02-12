class GamePlayer < ApplicationRecord
    belongs_to :game

    validates :name, presence: true, length: { minimum: 3, maximum: 50 }
    validates :player_type, presence: true
    validates :ai_level, presence: true
    validates_presence_of :game_id
end