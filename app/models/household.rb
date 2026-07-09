class Household < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :categories, dependent: :destroy
  has_many :expenses, dependent: :destroy

  validates :name, presence: true
  validates :invite_code, presence: true, uniqueness: true

  before_validation :ensure_invite_code, on: :create

  # Default starter categories seeded for a brand-new household. Whole dollars,
  # no cents. The owner can edit, add, or remove these later.
  DEFAULT_CATEGORIES = [
    { name: "Groceries",     emoji: "🛒", color: "#16a34a", budget_amount: 200, period: "weekly" },
    { name: "Eating out",    emoji: "🍔", color: "#f97316", budget_amount: 100, period: "weekly" },
    { name: "Transport",     emoji: "🚗", color: "#0ea5e9", budget_amount: 60,  period: "weekly" },
    { name: "Fun",           emoji: "🎉", color: "#a855f7", budget_amount: 75,  period: "weekly" },
    { name: "Bills",         emoji: "💡", color: "#eab308", budget_amount: 300, period: "monthly" },
    { name: "Subscriptions", emoji: "📺", color: "#ef4444", budget_amount: 50,  period: "monthly" },
    { name: "Shopping",      emoji: "🛍️", color: "#ec4899", budget_amount: 150, period: "monthly" }
  ].freeze

  def add_default_categories!
    DEFAULT_CATEGORIES.each_with_index do |attrs, index|
      categories.create!(attrs.merge(position: index))
    end
  end

  def regenerate_invite_code!
    update!(invite_code: self.class.generate_invite_code)
  end

  def self.generate_invite_code
    # Six readable characters, skipping easily confused glyphs (0/O, 1/I).
    alphabet = ("A".."Z").to_a - %w[I O] + ("2".."9").to_a
    loop do
      code = Array.new(6) { alphabet.sample }.join
      break code unless exists?(invite_code: code)
    end
  end

  private

  def ensure_invite_code
    self.invite_code ||= self.class.generate_invite_code
  end
end
