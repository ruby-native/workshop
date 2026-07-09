require "test_helper"

class RegistrationTest < ActionDispatch::IntegrationTest
  test "sign up creates a household seeded with categories and signs you in" do
    assert_difference [ "User.count", "Household.count" ], 1 do
      post registration_path, params: {
        user: { name: "Sam", email_address: "sam@example.com", password: "password" }
      }
    end
    assert_redirected_to root_path
    user = User.find_by(email_address: "sam@example.com")
    assert user.current_household, "expected a current household"
    assert user.current_household.categories.any?, "expected seeded categories"
    assert_equal "owner", user.memberships.first.role
  end

  test "sign up with a valid invite code joins that household" do
    code = households(:home).invite_code
    assert_no_difference "Household.count" do
      post registration_path, params: {
        user: { name: "Pat", email_address: "pat@example.com", password: "password" },
        invite_code: code
      }
    end
    assert_redirected_to root_path
    assert_equal households(:home), User.find_by(email_address: "pat@example.com").current_household
  end

  test "sign up with an unknown invite code is rejected" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: { name: "X", email_address: "x@example.com", password: "password" },
        invite_code: "NOPECODE"
      }
    end
    assert_response :unprocessable_entity
  end
end
