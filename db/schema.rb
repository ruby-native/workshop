# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_15_164805) do
  create_table "action_push_native_devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "platform", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_action_push_native_devices_on_owner"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "budget_amount", default: 0, null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.string "emoji"
    t.integer "household_id", null: false
    t.string "name", null: false
    t.string "period", default: "weekly", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "position"], name: "index_categories_on_household_id_and_position"
    t.index ["household_id"], name: "index_categories_on_household_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "household_id", null: false
    t.string "note"
    t.date "spent_on", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category_id", "spent_on"], name: "index_expenses_on_category_id_and_spent_on"
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["household_id", "spent_on"], name: "index_expenses_on_household_id_and_spent_on"
    t.index ["household_id"], name: "index_expenses_on_household_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "households", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invite_code", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_code"], name: "index_households_on_invite_code", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "household_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["household_id"], name: "index_memberships_on_household_id"
    t.index ["user_id", "household_id"], name: "index_memberships_on_user_id_and_household_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_household_id"
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["current_household_id"], name: "index_users_on_current_household_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "categories", "households"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "households"
  add_foreign_key "expenses", "users"
  add_foreign_key "memberships", "households"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "households", column: "current_household_id"
end
