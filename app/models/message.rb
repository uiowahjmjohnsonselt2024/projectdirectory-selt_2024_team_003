class Message < ActiveRecord::Base
  belongs_to :user
  validates :content, presence: true
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id'
end
