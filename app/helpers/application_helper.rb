module ApplicationHelper
  # Whole dollars, no cents. e.g. 1234 => "$1,234"
  def money(amount)
    number_to_currency(amount.to_i, precision: 0)
  end

  # Signed whole dollars for "remaining" / "over" copy. e.g. -40 => "-$40"
  def signed_money(amount)
    "#{'-' if amount.to_i.negative?}#{money(amount.abs)}"
  end

  # Clamp a percentage to a sensible progress-bar width.
  def bar_width(percent)
    [ [ percent.to_i, 0 ].max, 100 ].min
  end

  # State class for a budget bar based on how much is spent.
  def bar_state(percent)
    if percent >= 100 then "over"
    elsif percent >= 80 then "close"
    else "ok"
    end
  end
end
