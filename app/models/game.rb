class Game < ApplicationRecord
    validates :firstname, presence: true, length: { minimum: 3, maximum: 50 }
    validates :state, presence: true

end