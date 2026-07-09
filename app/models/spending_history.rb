# Past weeks and months with spending compared against the household's current
# budget. Historical budgets are not versioned, so each period is measured
# against today's category budgets, which is good enough for a personal tracker.
class SpendingHistory
  Period = Data.define(:label, :sub_label, :spent, :budget, :current) do
    def remaining = budget - spent
    def over? = spent > budget
    def current? = current

    def percent
      return 0 if budget.zero?
      [ ((spent.to_f / budget) * 100).round, 999 ].min
    end
  end

  def initialize(household, today: Date.current)
    @household = household
    @today = today
  end

  def weeks(count: 8)
    budget = @household.categories.weekly.sum(:budget_amount)
    (0...count).map do |offset|
      start = (@today - offset.weeks).beginning_of_week
      finish = start.end_of_week
      Period.new(
        label: week_label(start),
        sub_label: "#{start.strftime('%b %-d')} – #{finish.strftime('%b %-d')}",
        spent: spent_in(start..finish, "weekly"),
        budget: budget,
        current: offset.zero?
      )
    end
  end

  def months(count: 6)
    budget = @household.categories.monthly.sum(:budget_amount)
    (0...count).map do |offset|
      start = (@today - offset.months).beginning_of_month
      finish = start.end_of_month
      Period.new(
        label: start.strftime("%B %Y"),
        sub_label: nil,
        spent: spent_in(start..finish, "monthly"),
        budget: budget,
        current: offset.zero?
      )
    end
  end

  private

  def spent_in(range, period)
    @household.expenses.between(range)
      .joins(:category).where(categories: { period: period })
      .sum(:amount)
  end

  def week_label(start)
    case start
    when @today.beginning_of_week then "This week"
    when (@today - 1.week).beginning_of_week then "Last week"
    else "Week of #{start.strftime('%b %-d')}"
    end
  end
end
