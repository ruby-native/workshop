class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_reference :users, :current_household, foreign_key: { to_table: :households }
  end
end
