# frozen_string_literal: true

class User < ActiveRecord::Base
  has_secure_password

  # Associations
  has_many :skins, dependent: :destroy
  has_many :game_users
  has_many :games, through: :game_users
  has_many :friendships
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_friendships, source: :user
  has_many :sent_messages, class_name: "Message", foreign_key: "user_id"
  has_many :received_messages, class_name: "Message", foreign_key: "recipient_id"

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 25 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Returns the user's current skin
  def current_skin
    skins.find_by(current: true)
  end
end
