class Game < ApplicationRecord
    validates :firstname, presence: true, length: { minimum: 3, maximum: 50 }
    validates :state, presence: true

    after_initialize :init

    def init
        self.status = 'New'
    end
end