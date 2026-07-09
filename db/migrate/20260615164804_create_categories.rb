class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :emoji
      t.string :color
      t.integer :budget_amount, null: false, default: 0
      t.string :period, null: false, default: "weekly"
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :categories, [ :household_id, :position ]
  end
end
