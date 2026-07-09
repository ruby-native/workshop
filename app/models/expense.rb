class Expense < ApplicationRecord
  belongs_to :household
  belongs_to :category
  belongs_to :user

  validates :amount, numericality: { only_integer: true, greater_than: 0 }
  validates :spent_on, presence: true
  validate :category_belongs_to_household

  before_validation :apply_defaults

  scope :between, ->(range) { where(spent_on: range) }
  scope :recent, -> { order(spent_on: :desc, created_at: :desc) }

  private

  def apply_defaults
    self.spent_on ||= Date.current
    self.household_id ||= category&.household_id
  end

  def category_belongs_to_household
    return if category.nil? || household_id.nil?
    errors.add(:category, "is not in this budget") if category.household_id != household_id
  end
end
