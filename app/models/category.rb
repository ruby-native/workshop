class Category < ApplicationRecord
  PERIODS = %w[weekly monthly].freeze
  COLORS = %w[#16a34a #0ea5e9 #f97316 #a855f7 #ef4444 #eab308 #ec4899 #14b8a6 #6366f1 #f43f5e].freeze

  belongs_to :household
  has_many :expenses, dependent: :destroy

  validates :name, presence: true
  validates :period, inclusion: { in: PERIODS }
  validates :budget_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :weekly, -> { where(period: "weekly") }
  scope :monthly, -> { where(period: "monthly") }
  scope :ordered, -> { order(:position, :id) }

  def weekly?
    period == "weekly"
  end

  def monthly?
    period == "monthly"
  end

  def period_label
    weekly? ? "week" : "month"
  end
end
