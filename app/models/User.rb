# frozen_string_literal: true

# app/models/user.rb
class User < ActiveRecord::Base
  # Adds methods to set and authenticate against a BCrypt password.
  # Requires `password_digest` attribute to be present in the database.
  has_secure_password

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 25 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end


