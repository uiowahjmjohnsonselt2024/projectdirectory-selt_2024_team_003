class CreditCard < ActiveRecord::Base
  belongs_to :user

  attr_accessor :card_number, :cvv # Virtual attribute for the full card number

  validates :card_number, presence: true, length: { is: 19, message: "must be 16 digits" }, on: :create
  validates :last4, :expiration_month, :expiration_year, :card_type, presence: true
  validates :cvv, presence: true, length: { is: 3, message: "must be 3 digits" }, numericality: { only_integer: true }, on: :create
  validates :expiration_month, inclusion: { in: 1..12 }
  validates :expiration_year, numericality: { greater_than_or_equal_to: Date.today.year }
  validate :expiration_date_cannot_be_in_the_past

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

  def expiration_date_cannot_be_in_the_past
    # Check that the expiration month is valid
    unless (1..12).include?(expiration_month)
      errors.add(:expiration_month, "must be between 1 and 12")
      return
    end

    # Combine expiration month and year into a Date object
    begin
      expiration_date = Date.new(expiration_year, expiration_month, -1) # Last day of the month
    rescue ArgumentError
      errors.add(:base, "Invalid expiration date")
      return
    end

    # Validate that the expiration date is in the future
    if expiration_date < Date.today
      errors.add(:base, "The card has expired")
    end
  end
end
