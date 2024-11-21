class Game < ActiveRecord::Base
    validates :name, presence: true, length: { minimum: 0, maximum: 50 }
    validates_uniqueness_of :code
    has_many :game_users
    has_many :users, through: :game_users
  
    before_create :generate_unique_code
  
    private
  
    
    # Generates a unique 4-character code for this game.
    # This is called by the before_create callback.
    # The code is generated randomly and is checked for uniqueness before it is assigned.
    def generate_unique_code
      self.code ||= loop do
        random_code = SecureRandom.alphanumeric(4).upcase
        break random_code unless Game.exists?(code: random_code)
      end
    end
end
  