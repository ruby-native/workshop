class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
    @invite_code = params[:invite_code]
  end

  def create
    @user = User.new(user_params)
    @invite_code = params[:invite_code].to_s.strip.upcase
    household = @invite_code.present? ? Household.find_by(invite_code: @invite_code) : nil

    if @invite_code.present? && household.nil?
      @user.errors.add(:base, "That invite code didn't match a budget.")
      return render :new, status: :unprocessable_entity
    end

    if @user.save
      place_in_household(@user, household)
      start_new_session_for(@user)
      redirect_to after_authentication_url, notice: "Welcome to Penny Pincher!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
  end

  # Join the budget for a valid invite code, otherwise spin up a fresh one
  # seeded with starter categories.
  def place_in_household(user, household)
    if household
      user.memberships.create!(household:, role: "member")
    else
      household = Household.create!(name: "#{user.display_name.capitalize}'s budget")
      user.memberships.create!(household:, role: "owner")
      household.add_default_categories!
    end
    user.update!(current_household: household)
  end
end
