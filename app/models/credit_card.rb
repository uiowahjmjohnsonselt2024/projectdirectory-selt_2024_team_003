class CreditCard < ActiveRecord::Base
  belongs_to :user

  attr_accessor :card_number # Virtual attribute for the full card number

  validates :card_number, presence: true, length: { is: 16 }, numericality: { only_integer: true }, on: :create
  validates :last4, :expiration_month, :expiration_year, :card_type, presence: true
  validates :expiration_month, inclusion: { in: 1..12 }
  validates :expiration_year, numericality: { greater_than_or_equal_to: Date.today.year }

  before_validation :set_last4_and_type, if: :card_number_present?

  private

  def card_number_present?
    card_number.present?
  end

  def set_last4_and_type
    self.last4 = card_number[-4..]
    self.card_type = detect_card_type(card_number)
  end

  def detect_card_type(number)
    case number
    when /^4/ then 'Visa'
    when /^5[1-5]/ then 'MasterCard'
    when /^3[47]/ then 'American Express'
    when /^6(?:011|5)/ then 'Discover'
    else 'Unknown'
    end
  end
end
