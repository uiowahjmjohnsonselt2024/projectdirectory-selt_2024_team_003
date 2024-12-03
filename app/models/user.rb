# frozen_string_literal: true

# app/models/user.rb
class User < ActiveRecord::Base
  before_save :initialize_achievements

  # Adds methods to set and authenticate against a BCrypt password.
  # Requires `password_digest` attribute to be present in the database.
  has_secure_password
  has_many :game_users
  has_many :games, through: :game_users
  has_many :friendships
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_friendships, source: :user
  has_many :sent_messages, class_name: "Message", foreign_key: "user_id"
  has_many :received_messages, class_name: "Message", foreign_key: "recipient_id"

  # Validations
  validates :health, :attack, :defense, :iq, presence: true, numericality: { only_integer: true }
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 25 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def set_archetype_stats(archetype)
    case archetype
    when 'Arcane Strategist'
      self.archetype = 'Arcane Strategist'
      self.attack = 30
      self.iq = 10
      self.defense = 5
      self.health = 100
      self.special_attack = 40
      self.special_defense = 20
      self.mana = 100
    when 'Iron Guardian'
      self.archetype = 'Iron Guardian'
      self.attack = 10
      self.iq = 1
      self.defense = 30
      self.health = 200
      self.special_attack = 15
      self.special_defense = 35
      self.mana = 50
    when 'Omni Knight'
      self.archetype = 'Omni Knight'
      self.attack = 20
      self.iq = 5
      self.defense = 20
      self.health = 150
      self.special_attack = 25
      self.special_defense = 25
      self.mana = 75
    else
      self.archetype = 'Omni Knight' # just go to balanced build if not gone through
      self.attack = 20
      self.iq = 5
      self.defense = 20
      self.health = 150
      self.special_attack = 25
      self.special_defense = 25
      self.mana = 75
    end
    save
  end

  def level_up
    self.experience -= self.level * 100
    self.level += 1
    stat_increase = case archetype
                    when 'Arcane Strategist'
                      { health: 20, attack: 10, defense: 5, iq: 3, mana: 20, special_attack: 10, special_defense: 5 }
                    when 'Iron Guardian'
                      { health: 30, attack: 5, defense: 10, iq: 1, mana: 10, special_attack: 5, special_defense: 10 }
                    when 'Omni Knight'
                      { health: 25, attack: 7, defense: 7, iq: 2, mana: 15, special_attack: 7, special_defense: 7 }
                    else
                      { health: 25, attack: 7, defense: 7, iq: 2, mana: 15, special_attack: 4, special_defense: 4 }
                    end

    self.health += stat_increase[:health]
    self.attack += stat_increase[:attack]
    self.defense += stat_increase[:defense]
    self.iq += stat_increase[:iq]
    self.mana += stat_increase[:mana]
    self.special_attack += stat_increase[:special_attack]
    self.special_defense += stat_increase[:special_defense]

    save!

    game_users.each { |game_user| game_user.update_health_and_mana }
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
end


