class SummaryController < ApplicationController
  before_action :require_household

  def show
    @history = SpendingHistory.new(current_household)
  end
end
