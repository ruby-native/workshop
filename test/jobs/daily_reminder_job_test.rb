require "test_helper"

class DailyReminderJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @household = Household.create!(name: "Reminders")
    @category = @household.categories.create!(name: "Food", budget_amount: 50, period: "weekly", color: "#000000")
    @user = User.create!(email_address: "remind@example.com", password: "password", name: "R")
    @user.memberships.create!(household: @household, role: "owner")
    @user.update!(current_household: @household)
  end

  test "reminds a user with a device who hasn't logged today" do
    @user.push_devices.create!(platform: "apple", token: "tok-1")
    with_push_enabled do
      assert_enqueued_jobs 1, only: ApplicationPushNotificationJob do
        DailyReminderJob.perform_now
      end
    end
  end

  test "skips a user who already logged today" do
    @user.push_devices.create!(platform: "apple", token: "tok-2")
    @household.expenses.create!(category: @category, user: @user, amount: 5, spent_on: Date.current)
    with_push_enabled do
      assert_no_enqueued_jobs only: ApplicationPushNotificationJob do
        DailyReminderJob.perform_now
      end
    end
  end

  test "skips a user without a device" do
    with_push_enabled do
      assert_no_enqueued_jobs only: ApplicationPushNotificationJob do
        DailyReminderJob.perform_now
      end
    end
  end

  private

  def with_push_enabled
    ApplicationPushNotification.enabled = true
    yield
  ensure
    ApplicationPushNotification.enabled = false
  end
end
