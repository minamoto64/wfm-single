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

ActiveRecord::Schema[8.1].define(version: 2026_01_30_101208) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.text "key_notes"
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["uuid"], name: "index_customers_on_uuid", unique: true
  end

  create_table "interactions", force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "interaction_type", null: false
    t.datetime "occurred_at", null: false
    t.bigint "parent_interaction_id"
    t.text "request_content", null: false
    t.text "response_result", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["customer_id", "occurred_at"], name: "index_interactions_on_customer_id_and_occurred_at"
    t.index ["interaction_type"], name: "index_interactions_on_interaction_type"
    t.index ["parent_interaction_id"], name: "index_interactions_on_parent_interaction_id"
    t.index ["user_id", "occurred_at"], name: "index_interactions_on_user_id_and_occurred_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "interactions", "customers"
  add_foreign_key "interactions", "interactions", column: "parent_interaction_id"
  add_foreign_key "interactions", "users"
  add_foreign_key "sessions", "users"
end
