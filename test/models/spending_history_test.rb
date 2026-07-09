require "test_helper"

class SpendingHistoryTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "SH")
    @weekly = @household.categories.create!(name: "Food", budget_amount: 100, period: "weekly", color: "#000000")
    @monthly = @household.categories.create!(name: "Rent", budget_amount: 300, period: "monthly", color: "#000000")
    @user = users(:one)
    @household.expenses.create!(category: @weekly, user: @user, amount: 30, spent_on: Date.current)
    @household.expenses.create!(category: @weekly, user: @user, amount: 40, spent_on: Date.current - 1.week) # last week
    @household.expenses.create!(category: @monthly, user: @user, amount: 50, spent_on: Date.current)
  end

  test "weeks split spending across this week and last week" do
    weeks = SpendingHistory.new(@household).weeks(count: 2)
    assert_equal "This week", weeks[0].label
    assert weeks[0].current?
    assert_equal 30, weeks[0].spent
    assert_equal 100, weeks[0].budget
    assert_equal "Last week", weeks[1].label
    assert_equal 40, weeks[1].spent
  end

  test "months sum the current month against the monthly budget" do
    month = SpendingHistory.new(@household).months(count: 1).first
    assert_equal 50, month.spent
    assert_equal 300, month.budget
    assert_not month.over?
  end
end
