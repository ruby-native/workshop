require "test_helper"

class HouseholdTest < ActiveSupport::TestCase
  test "generates a unique uppercase invite code on create" do
    household = Household.create!(name: "Test")
    assert_match(/\A[A-Z2-9]{6}\z/, household.invite_code)
  end

  test "keeps an explicitly provided invite code" do
    household = Household.create!(name: "Test", invite_code: "ABC123")
    assert_equal "ABC123", household.invite_code
  end

  test "invite code must be unique" do
    Household.create!(name: "A", invite_code: "DUPED1")
    dup = Household.new(name: "B", invite_code: "DUPED1")
    assert_not dup.valid?
  end

  test "add_default_categories! seeds weekly and monthly budgets" do
    household = Household.create!(name: "Fresh")
    assert_difference -> { household.categories.count }, Household::DEFAULT_CATEGORIES.size do
      household.add_default_categories!
    end
    assert household.categories.weekly.any?
    assert household.categories.monthly.any?
  end

  test "regenerate_invite_code! changes the code" do
    household = Household.create!(name: "Test")
    original = household.invite_code
    household.regenerate_invite_code!
    assert_not_equal original, household.invite_code
  end
end
