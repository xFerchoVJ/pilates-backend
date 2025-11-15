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

ActiveRecord::Schema[7.2].define(version: 2025_11_14_210546) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blacklisted_tokens", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_blacklisted_tokens_on_jti", unique: true
  end

  create_table "class_packages", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "class_count", null: false
    t.integer "price", null: false
    t.string "currency", default: "mxn", null: false
    t.boolean "status", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "class_sessions", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.bigint "instructor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "lounge_id"
    t.integer "price"
    t.index ["instructor_id"], name: "index_class_sessions_on_instructor_id"
    t.index ["lounge_id"], name: "index_class_sessions_on_lounge_id"
  end

  create_table "class_spaces", force: :cascade do |t|
    t.bigint "class_session_id", null: false
    t.string "label"
    t.integer "x"
    t.integer "y"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_session_id"], name: "index_class_spaces_on_class_session_id"
  end

  create_table "class_waitlist_notifications", force: :cascade do |t|
    t.bigint "class_session_id", null: false
    t.bigint "user_id", null: false
    t.datetime "notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_session_id", "user_id"], name: "idx_on_class_session_id_user_id_b51f4eb9ca", unique: true
    t.index ["class_session_id"], name: "index_class_waitlist_notifications_on_class_session_id"
    t.index ["user_id"], name: "index_class_waitlist_notifications_on_user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "expo_push_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "injuries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "injury_type"
    t.text "description"
    t.string "severity"
    t.date "date_ocurred"
    t.boolean "recovered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_injuries_on_user_id"
  end

  create_table "lounge_designs", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.jsonb "layout_json", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lounges", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "lounge_design_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lounge_design_id"], name: "index_lounges_on_lounge_design_id"
  end

  create_table "refresh_token_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "jti"
    t.string "user_agent"
    t.string "ip"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_refresh_token_users_on_jti"
    t.index ["user_id"], name: "index_refresh_token_users_on_user_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "class_session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "class_space_id", null: false
    t.boolean "status", default: true
    t.index ["class_session_id"], name: "index_reservations_on_class_session_id"
    t.index ["class_space_id"], name: "index_reservations_on_class_space_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount", null: false
    t.string "currency", default: "mxn", null: false
    t.string "transaction_type", null: false
    t.integer "reference_id", null: false
    t.string "reference_type", null: false
    t.string "payment_intent_id", null: false
    t.jsonb "metadata"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_class_packages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "class_package_id", null: false
    t.integer "remaining_classes", null: false
    t.string "status", default: "active", null: false
    t.datetime "purchased_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_package_id"], name: "index_user_class_packages_on_class_package_id"
    t.index ["user_id"], name: "index_user_class_packages_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "name"
    t.string "last_name"
    t.string "phone"
    t.integer "role"
    t.string "provider"
    t.string "uid"
    t.boolean "google_email_verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gender", null: false
    t.date "birthdate", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "has_injuries", default: "pending", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "class_sessions", "lounges"
  add_foreign_key "class_sessions", "users", column: "instructor_id"
  add_foreign_key "class_spaces", "class_sessions"
  add_foreign_key "class_waitlist_notifications", "class_sessions"
  add_foreign_key "class_waitlist_notifications", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "injuries", "users"
  add_foreign_key "lounges", "lounge_designs"
  add_foreign_key "refresh_token_users", "users"
  add_foreign_key "reservations", "class_sessions"
  add_foreign_key "reservations", "class_spaces"
  add_foreign_key "reservations", "users"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_class_packages", "class_packages"
  add_foreign_key "user_class_packages", "users"
end
