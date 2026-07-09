require "test_helper"

class BudgetSummaryTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "BS")
    @weekly = @household.categories.create!(name: "Food", budget_amount: 100, period: "weekly", color: "#000000")
    @monthly = @household.categories.create!(name: "Rent", budget_amount: 300, period: "monthly", color: "#000000")
    @user = users(:one)
    @household.expenses.create!(category: @weekly, user: @user, amount: 30, spent_on: Date.current)
    @household.expenses.create!(category: @weekly, user: @user, amount: 40, spent_on: Date.current - 1.week) # last week
    @household.expenses.create!(category: @monthly, user: @user, amount: 50, spent_on: Date.current)
  end

  test "weekly totals only count the current week" do
    summary = BudgetSummary.new(@household)
    assert_equal 100, summary.weekly_budget
    assert_equal 30, summary.weekly_spent
    assert_equal 70, summary.weekly_remaining
  end

  test "monthly totals count the current month" do
    summary = BudgetSummary.new(@household)
    assert_equal 300, summary.monthly_budget
    assert_equal 50, summary.monthly_spent
  end

  test "category progress flags over budget" do
    @household.expenses.create!(category: @weekly, user: @user, amount: 90, spent_on: Date.current)
    food = BudgetSummary.new(@household).weekly.find { |c| c.name == "Food" }
    assert_equal 120, food.spent
    assert food.over?
    assert_equal 120, food.percent
  end
end
