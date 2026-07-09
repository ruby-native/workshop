# Computes spending vs. budget for a household over the current week and month.
# All amounts are whole dollars (no cents).
class BudgetSummary
  CategoryProgress = Data.define(:category, :spent) do
    def budget = category.budget_amount
    def remaining = budget - spent
    def over? = spent > budget
    def name = category.name
    def emoji = category.emoji
    def color = category.color

    def percent
      return 0 if budget.zero?
      [ ((spent.to_f / budget) * 100).round, 999 ].min
    end
  end

  def initialize(household, date: Date.current)
    @household = household
    @date = date
  end

  def week_range = @date.beginning_of_week..@date.end_of_week
  def month_range = @date.beginning_of_month..@date.end_of_month

  def weekly = @weekly ||= build(@household.categories.weekly.ordered, week_range)
  def monthly = @monthly ||= build(@household.categories.monthly.ordered, month_range)

  def weekly_budget = weekly.sum(&:budget)
  def weekly_spent = weekly.sum(&:spent)
  def weekly_remaining = weekly_budget - weekly_spent
  def weekly_percent = percent(weekly_spent, weekly_budget)

  def monthly_budget = monthly.sum(&:budget)
  def monthly_spent = monthly.sum(&:spent)
  def monthly_remaining = monthly_budget - monthly_spent
  def monthly_percent = percent(monthly_spent, monthly_budget)

  # Whole-month snapshot across every category: all spending this month vs. the
  # total budget, with weekly budgets scaled up to the length of the month.
  def month_label = @date.strftime("%B")
  def snapshot_spent = @snapshot_spent ||= @household.expenses.between(month_range).sum(:amount)
  def snapshot_budget = monthly_budget + (weekly_budget * weeks_in_month).round
  def snapshot_remaining = snapshot_budget - snapshot_spent
  def snapshot_percent = percent(snapshot_spent, snapshot_budget)

  def any_categories? = weekly.any? || monthly.any?

  private

  # Approximate weeks in the month (e.g. 30 / 7) so a per-week budget can be
  # compared against a full month of spending.
  def weeks_in_month = @date.end_of_month.day / 7.0

  def build(categories, range)
    spent_by_category = @household.expenses.between(range).group(:category_id).sum(:amount)
    categories.map do |category|
      CategoryProgress.new(category:, spent: spent_by_category[category.id] || 0)
    end
  end

  def percent(spent, budget)
    return 0 if budget.zero?
    [ ((spent.to_f / budget) * 100).round, 999 ].min
  end
end
