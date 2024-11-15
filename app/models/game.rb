class Game < ActiveRecord::Base
    validates :name, presence: true, length: { minimum: 0, maximum: 50 }
    validates_uniqueness_of :code
    has_many :game_users
    has_many :users, through: :game_users
  
    before_create :generate_unique_code
  
    private
  
    # Generate a unique 4-character game code
    def generate_unique_code
      self.code ||= loop do
        random_code = SecureRandom.alphanumeric(4).upcase
        break random_code unless Game.exists?(code: random_code)
      end
    end
end
  