# Demo data for local review. Idempotent and development-only.
if Rails.env.development?
  joe = User.find_or_create_by!(email_address: "joe@example.com") do |u|
    u.name = "Joe"
    u.password = "password"
  end

  household = joe.households.first
  unless household
    household = Household.create!(name: "Masilotti budget")
    joe.memberships.create!(household: household, role: "owner")
    household.add_default_categories!
    joe.update!(current_household: household)
  end

  age = User.find_or_create_by!(email_address: "age@example.com") do |u|
    u.name = "Age"
    u.password = "password"
  end
  unless age.member_of?(household)
    age.memberships.create!(household: household, role: "member")
    age.update!(current_household: household)
  end

  if household.expenses.none?
    by_name = household.categories.index_by(&:name)
    [
      [ "Groceries",     64,  0, "Trader Joe's", joe ],
      [ "Groceries",     38,  2, nil,            age ],
      [ "Eating out",    22,  1, "Tacos",        joe ],
      [ "Eating out",    47,  3, "Date night",   age ],
      [ "Transport",     18,  1, "Gas",          joe ],
      [ "Fun",           30,  4, "Mini golf",    age ],
      [ "Bills",        120,  6, "Electric",     joe ],
      [ "Subscriptions", 15,  9, "Streaming",    joe ],
      [ "Shopping",      56,  5, "Shoes",        age ]
    ].each do |name, amount, days_ago, note, who|
      category = by_name[name] or next
      household.expenses.create!(category: category, user: who, amount: amount,
                                 note: note, spent_on: Date.current - days_ago)
    end
  end

  puts "Seeded. Sign in as joe@example.com / password (or age@example.com / password)."
end
