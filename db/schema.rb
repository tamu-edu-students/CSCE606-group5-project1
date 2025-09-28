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

ActiveRecord::Schema[8.0].define(version: 2025_09_28_013946) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "summary"
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "user_id" ], name: "index_events_on_user_id"
  end

  create_table "leet_code_entries", force: :cascade do |t|
    t.integer "problem_number", null: false
    t.string "problem_title"
    t.integer "difficulty", null: false
    t.date "solved_on", default: -> { "CURRENT_DATE" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "problem_number" ], name: "index_leet_code_entries_on_problem_number"
    t.index [ "solved_on" ], name: "index_leet_code_entries_on_solved_on"
  end

  create_table "leet_code_problems", force: :cascade do |t|
    t.string "leetcode_id", null: false
    t.string "title"
    t.string "difficulty"
    t.string "url"
    t.text "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "leetcode_id" ], name: "index_leet_code_problems_on_leetcode_id", unique: true
  end

  create_table "leet_code_session_problems", force: :cascade do |t|
    t.bigint "leet_code_session_id", null: false
    t.bigint "leet_code_problem_id", null: false
    t.boolean "solved", default: false
    t.datetime "solved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "leet_code_problem_id" ], name: "index_leet_code_session_problems_on_leet_code_problem_id"
    t.index [ "leet_code_session_id" ], name: "index_leet_code_session_problems_on_leet_code_session_id"
  end

  create_table "leet_code_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "scheduled_time"
    t.integer "duration_minutes"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "user_id" ], name: "index_leet_code_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "netid"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_streak"
    t.integer "longest_streak"
    t.text "preferred_topics"
    t.index [ "email" ], name: "index_users_on_email", unique: true
    t.index [ "netid" ], name: "index_users_on_netid", unique: true
  end

  add_foreign_key "events", "users"
  add_foreign_key "leet_code_session_problems", "leet_code_problems"
  add_foreign_key "leet_code_session_problems", "leet_code_sessions"
  add_foreign_key "leet_code_sessions", "users"
end
