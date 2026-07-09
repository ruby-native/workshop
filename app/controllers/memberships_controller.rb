class MembershipsController < ApplicationController
  before_action :require_household

  def destroy
    membership = current_household.memberships.find(params[:id])
    current_membership = current_household.memberships.find_by(user: current_user)

    if membership.user_id != current_user.id && !current_membership&.owner?
      return redirect_to settings_path, alert: "Only an owner can remove members."
    end

    leaving_self = membership.user_id == current_user.id
    membership.destroy

    if leaving_self
      next_household = current_user.households.first
      current_user.update!(current_household: next_household)
      destination = next_household ? root_path : new_household_path
      redirect_to destination, notice: "You left the budget.", status: :see_other
    else
      redirect_to settings_path, notice: "Member removed.", status: :see_other
    end
  end
end
