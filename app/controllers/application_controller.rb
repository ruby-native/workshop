class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :current_household

  private

  # Used by views, controllers, and the Ruby Native push device endpoint.
  def current_user
    Current.user
  end

  # The household the signed-in user is currently budgeting in.
  def current_household
    return @current_household if defined?(@current_household)
    @current_household = current_user&.active_household
  end

  # Guards screens that need a household. Sends members without one into onboarding.
  def require_household
    redirect_to new_household_path unless current_household
  end
end
