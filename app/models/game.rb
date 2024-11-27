class Game < ActiveRecord::Base
    validates :name, presence: true, length: { minimum: 0, maximum: 50 }
    validates_uniqueness_of :code
    has_many :game_users
    has_many :users, through: :game_users
    has_many :enemies

    before_create :generate_unique_code
    after_create :generate_enemies

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

    def generate_enemies
      # Generate an enemy for each grid square (you can adjust the number of grid squares)
      grid_size = 10  # For example, a 10x10 grid
      grid_size.times do |x|
        grid_size.times do |y|
          enemies.create(
            name: "Enemy #{x},#{y}",
            health: 300,
            attack: 20,
            defense: 10,
            iq: 5,
            x_position: x,
            y_position: y
          )
        end
      end
    end
end
  