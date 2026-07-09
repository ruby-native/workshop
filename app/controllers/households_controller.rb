class HouseholdsController < ApplicationController
  before_action :set_household, only: %i[ edit update switch regenerate_invite ]

  # Onboarding for a user who belongs to no household (e.g. after leaving one).
  def new
    @household = Household.new
  end

  def create
    @household = Household.new(household_params)
    if @household.save
      current_user.memberships.create!(household: @household, role: "owner")
      @household.add_default_categories!
      current_user.update!(current_household: @household)
      redirect_to root_path, notice: "Budget created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @household.update(household_params)
      redirect_to settings_path, notice: "Budget renamed."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def switch
    current_user.update!(current_household: @household)
    redirect_to root_path
  end

  def regenerate_invite
    @household.regenerate_invite_code!
    redirect_to settings_path, notice: "New invite code generated."
  end

  private

  # Scope to the user's own households so they can't touch one they're not in.
  def set_household
    @household = current_user.households.find(params[:id])
  end

  def household_params
    params.expect(household: [ :name ])
  end
end
