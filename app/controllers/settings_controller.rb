class SettingsController < ApplicationController
  before_action :require_household

  def show
    @household = current_household
    @members = @household.memberships.includes(:user).order(:created_at)
    @current_membership = @members.find { |m| m.user_id == current_user.id }
    @categories = @household.categories.ordered
    @other_households = current_user.households.where.not(id: @household.id)
  end
end
