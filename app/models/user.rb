# frozen_string_literal: true

# app/models/user.rb
class User < ActiveRecord::Base
  # Adds methods to set and authenticate against a BCrypt password.
  # Requires `password_digest` attribute to be present in the database.
  has_secure_password
  has_many :game_users
  has_many :games, through: :game_users

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 25 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Generate a reset password token and set its expiration time
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.hex(10) # generates a random token
    self.reset_password_sent_at = Time.now.utc # store the time when token is generated
    save!
  end

  # Check if the reset password token is valid
  def reset_password_token_valid?(token)
    self.reset_password_token == token # && (self.reset_password_sent_at + 1.hour) < Time.now.utc
  end
end


