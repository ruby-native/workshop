# Runs every day at 5pm (see config/recurring.yml). Nudges anyone who hasn't
# logged an expense yet today, but only if they have a registered push device.
class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform(date: Date.current)
    reminder_candidates.find_each do |user|
      next if logged_today?(user, date)

      devices = user.push_devices
      next if devices.none?

      ApplicationPushNotification.new(
        title: "Track today's spending ¢",
        body: "You haven't logged anything yet. Tap to add an expense.",
        data: { path: "/expenses/new" }
      ).deliver_later_to(devices)
    end
  end

  private

  # Only users who are budgeting and have at least one push device.
  def reminder_candidates
    device_owner_ids = ApplicationPushDevice.where(owner_type: "User").select(:owner_id)
    User.where.not(current_household_id: nil).where(id: device_owner_ids)
  end

  def logged_today?(user, date)
    user.expenses.where(household_id: user.current_household_id, spent_on: date).exists?
  end
end
