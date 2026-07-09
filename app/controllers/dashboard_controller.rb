class DashboardController < ApplicationController
  before_action :require_household

  def show
    @summary = BudgetSummary.new(current_household)
    @recent_expenses = current_household.expenses.recent.includes(:category, :user).limit(8)
    @logged_today = current_user.expenses
      .where(household: current_household, spent_on: Date.current).exists?
  end
end
