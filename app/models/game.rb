class Game < ApplicationRecord
    has_many :game_players, dependent: :destroy

    validates :firstname, presence: true, length: { minimum: 3, maximum: 50 }
    validates :state, presence: true
    validates_associated :game_players
end