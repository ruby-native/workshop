class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :households, through: :memberships
  has_many :expenses, dependent: :destroy
  has_many :push_devices, class_name: "ApplicationPushDevice", as: :owner, dependent: :destroy
  belongs_to :current_household, class_name: "Household", optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true

  # Display name, falling back to the local part of the email address.
  def display_name
    name.presence || email_address.split("@").first
  end

  def initials
    display_name.split(/[\s@._-]/).reject(&:blank?).first(2).map { |part| part[0] }.join.upcase
  end

  def member_of?(household)
    household && memberships.exists?(household_id: household.id)
  end

  # The household to land on, preferring the current one but falling back to
  # any the user belongs to.
  def active_household
    current_household || households.first
  end
end
