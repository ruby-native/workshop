require "test_helper"

class ExpensesFlowTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "home renders the budget overview" do
    get root_path
    assert_response :success
    assert_select "h1", text: /Where you stand/
  end

  test "logging an expense saves it to the current household" do
    assert_difference -> { households(:home).expenses.count }, 1 do
      post expenses_path, params: {
        expense: { amount: 25, category_id: categories(:groceries).id, note: "Lunch", spent_on: Date.current }
      }
    end
    assert_redirected_to root_path
    expense = households(:home).expenses.order(:created_at).last
    assert_equal users(:one), expense.user
    assert_equal 25, expense.amount
  end

  test "joining via code switches the current household" do
    sign_in_as(users(:two))
    post join_path, params: { invite_code: households(:home).invite_code }
    assert_redirected_to root_path
    assert_equal households(:home), users(:two).reload.current_household
  end
end
