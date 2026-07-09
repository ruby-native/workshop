class JoinsController < ApplicationController
  def new
  end

  def create
    code = params[:invite_code].to_s.strip.upcase
    household = Household.find_by(invite_code: code)

    if household.nil?
      flash.now[:alert] = "That invite code didn't match a budget."
      return render :new, status: :unprocessable_entity
    end

    unless current_user.member_of?(household)
      current_user.memberships.create!(household:, role: "member")
    end
    current_user.update!(current_household: household)
    redirect_to root_path, notice: "You joined #{household.name}."
  end
end
