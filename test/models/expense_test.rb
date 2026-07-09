require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  setup do
    @household = households(:home)
    @category = categories(:groceries)
    @user = users(:one)
  end

  test "defaults spent_on to today and household from category" do
    expense = Expense.new(category: @category, user: @user, amount: 10)
    assert expense.valid?
    assert_equal Date.current, expense.spent_on
    assert_equal @category.household_id, expense.household_id
  end

  test "amount must be a positive integer" do
    expense = Expense.new(household: @household, category: @category, user: @user, amount: 0)
    assert_not expense.valid?
    assert_includes expense.errors[:amount], "must be greater than 0"
  end

  test "rejects a category from another household" do
    other = Household.create!(name: "Other")
    foreign = other.categories.create!(name: "Misc", budget_amount: 10, period: "weekly")
    expense = Expense.new(household: @household, category: foreign, user: @user, amount: 5)
    assert_not expense.valid?
    assert_includes expense.errors[:category], "is not in this budget"
  end
end
