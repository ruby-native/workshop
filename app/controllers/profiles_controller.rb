class ProfilesController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to settings_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    permitted = params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
    permitted = permitted.except(:password, :password_confirmation) if permitted[:password].blank?
    permitted
  end
end
