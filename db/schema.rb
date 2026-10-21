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

ActiveRecord::Schema[8.1].define(version: 2026_06_27_150739) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.bigint "analysis_type_id", null: false
    t.datetime "created_at", null: false
    t.bigint "pet_history_id", null: false
    t.text "result"
    t.datetime "updated_at", null: false
    t.index ["analysis_type_id"], name: "index_analyses_on_analysis_type_id"
    t.index ["pet_history_id"], name: "index_analyses_on_pet_history_id"
  end

  create_table "analysis_types", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "pet_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "pet_id", null: false
    t.datetime "updated_at", null: false
    t.datetime "visit_date", null: false
    t.index ["pet_id"], name: "index_pet_histories_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.date "birth_date"
    t.string "breed"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "species", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_pets_on_client_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "pet_history_id", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_history_id"], name: "index_recommendations_on_pet_history_id"
  end

  create_table "treatments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "pet_history_id", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_history_id"], name: "index_treatments_on_pet_history_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "analyses", "analysis_types"
  add_foreign_key "analyses", "pet_histories"
  add_foreign_key "clients", "users"
  add_foreign_key "pet_histories", "pets"
  add_foreign_key "pets", "clients"
  add_foreign_key "recommendations", "pet_histories"
  add_foreign_key "treatments", "pet_histories"
end
