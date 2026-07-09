class Membership < ApplicationRecord
  ROLES = %w[owner member].freeze

  belongs_to :user
  belongs_to :household

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :household_id }

  def owner?
    role == "owner"
  end
end
