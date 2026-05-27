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

ActiveRecord::Schema[8.1].define(version: 2026_05_27_134402) do
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

  create_table "interaction_notices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "interaction_id", null: false
    t.bigint "notice_id", null: false
    t.datetime "updated_at", null: false
    t.index ["interaction_id", "notice_id"], name: "index_interaction_notices_on_interaction_id_and_notice_id", unique: true
    t.index ["interaction_id"], name: "index_interaction_notices_on_interaction_id"
    t.index ["notice_id"], name: "index_interaction_notices_on_notice_id"
  end

  create_table "interaction_tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "interaction_id", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["interaction_id", "task_id"], name: "index_interaction_tasks_on_interaction_id_and_task_id", unique: true
    t.index ["interaction_id"], name: "index_interaction_tasks_on_interaction_id"
    t.index ["task_id"], name: "index_interaction_tasks_on_task_id"
  end

  create_table "interactions", force: :cascade do |t|
    t.string "channel", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "occurred_at", null: false
    t.bigint "parent_id"
    t.text "request_content", null: false
    t.text "response_result", null: false
    t.bigint "root_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["channel"], name: "index_interactions_on_channel"
    t.index ["customer_id", "occurred_at"], name: "index_interactions_on_customer_id_and_occurred_at"
    t.index ["parent_id"], name: "index_interactions_on_parent_id"
    t.index ["root_id"], name: "index_interactions_on_root_id"
    t.index ["user_id", "occurred_at"], name: "index_interactions_on_user_id_and_occurred_at"
  end

  create_table "notice_tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "notice_id", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["notice_id", "task_id"], name: "index_notice_tasks_on_notice_id_and_task_id", unique: true
    t.index ["notice_id"], name: "index_notice_tasks_on_notice_id"
    t.index ["task_id"], name: "index_notice_tasks_on_task_id"
  end

  create_table "notices", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "end_at", null: false
    t.string "level", null: false
    t.bigint "parent_id"
    t.boolean "restricted", default: false, null: false
    t.bigint "root_id"
    t.datetime "start_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["level"], name: "index_notices_on_level"
    t.index ["parent_id"], name: "index_notices_on_parent_id"
    t.index ["root_id"], name: "index_notices_on_root_id"
    t.index ["start_at", "end_at"], name: "index_notices_on_start_at_and_end_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "task_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["task_id", "user_id"], name: "index_task_assignments_on_task_id_and_user_id", unique: true
    t.index ["task_id"], name: "index_task_assignments_on_task_id"
    t.index ["user_id"], name: "index_task_assignments_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.datetime "due_at"
    t.bigint "parent_id"
    t.boolean "restricted", default: false, null: false
    t.bigint "root_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["due_at"], name: "index_tasks_on_due_at"
    t.index ["parent_id"], name: "index_tasks_on_parent_id"
    t.index ["root_id"], name: "index_tasks_on_root_id"
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

  add_foreign_key "interaction_notices", "interactions"
  add_foreign_key "interaction_notices", "notices"
  add_foreign_key "interaction_tasks", "interactions"
  add_foreign_key "interaction_tasks", "tasks"
  add_foreign_key "interactions", "customers"
  add_foreign_key "interactions", "interactions", column: "parent_id"
  add_foreign_key "interactions", "interactions", column: "root_id"
  add_foreign_key "interactions", "users"
  add_foreign_key "notice_tasks", "notices"
  add_foreign_key "notice_tasks", "tasks"
  add_foreign_key "notices", "notices", column: "parent_id"
  add_foreign_key "notices", "notices", column: "root_id"
  add_foreign_key "notices", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "task_assignments", "tasks"
  add_foreign_key "task_assignments", "users"
  add_foreign_key "tasks", "tasks", column: "parent_id"
  add_foreign_key "tasks", "tasks", column: "root_id"
  add_foreign_key "tasks", "users"
end
