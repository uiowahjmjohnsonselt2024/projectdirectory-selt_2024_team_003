class UserMove < ActiveRecord::Base
  belongs_to :user
  belongs_to :move

  validate :move_limit

  def move_limit
    if user.moves.count >= 4
      errors.add(:base, "A user cannot have more than 4 moves.")
    end
  end
end
