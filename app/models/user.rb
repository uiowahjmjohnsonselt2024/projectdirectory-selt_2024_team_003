# frozen_string_literal: true

# app/models/user.rb
class User < ActiveRecord::Base
  before_save :initialize_achievements

  # Adds methods to set and authenticate against a BCrypt password.
  # Requires `password_digest` attribute to be present in the database.
  has_secure_password

  # Associations
  has_many :skins, dependent: :destroy
  has_many :weapons, dependent: :destroy
  has_many :game_users
  has_many :games, through: :game_users
  has_many :friendships
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :inverse_friends, through: :inverse_friendships, source: :user
  has_one :credit_card, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'user_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id'

  # Validations
  validates :username, presence: { message: "Username is required" },
            uniqueness: { message: "Username has already been taken" },
            length: { minimum: 3, maximum: 20, message: "Username must be between 3 and 20 characters" }

  validates :email, presence: { message: "Email is required" },
            uniqueness: { message: "Email has already been taken" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email format" }

  validates :password, length: { minimum: 6, message: "Password must be at least 6 characters long" },
            if: -> { new_record? || !password.nil? }

  # Generate a reset password token and set its expiration time
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.hex(10) # generates a random token
    self.reset_password_sent_at = Time.now.utc # store the time when token is generated
    save!
  end

  # Check if the reset password token is valid
  def reset_password_token_valid?(token)
    self.reset_password_token == token && self.reset_password_sent_at >= Time.now.utc - 1.hour
  end

  validates :health, :attack, :defense, :iq, presence: true, numericality: { only_integer: true }
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 25 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Returns the user's current skin
  def current_skin
    skins.find_by(current: true)
  end


  def add_achievement(achievement)
    self.achievements ||= []
    unless achievements.include?(achievement)
      achievements << achievement
      save!
    end
  end

  def initialize_achievements
    self.achievements ||= []
  end

  def check_milestone_achievements
    milestones = {
      5 => 'Level 5: Novice Hero',
      10 => 'Level 10: Experienced Warrior',
      25 => 'Level 25: Master of the Grid',
      50 => 'Level 50: Legend of the Game',
      100 => 'Level 100: Immortal',
    }

    if milestones.key?(level)
      achievement = milestones[level]
      add_achievement(achievement)
    end
  end

  # Returns true if the user has a credit card, false otherwise.
  def has_credit_card?
    credit_card.present?
  end
end


