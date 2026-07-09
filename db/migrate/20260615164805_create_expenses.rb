class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :household, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.string :note
      t.date :spent_on, null: false

      t.timestamps
    end
    add_index :expenses, [ :household_id, :spent_on ]
    add_index :expenses, [ :category_id, :spent_on ]
  end
end
