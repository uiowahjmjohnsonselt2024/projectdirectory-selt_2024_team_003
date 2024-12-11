# frozen_string_literal: true

# app/models/user.rb
class User < ActiveRecord::Base
  # Adds methods to set and authenticate against a BCrypt password.
  # Requires `password_digest` attribute to be present in the database.
  has_secure_password
  has_many :game_users
  has_many :games, through: :game_users

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
end


