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

ActiveRecord::Schema[8.0].define(version: 2024_11_21_222758) do
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

  create_table "notifications", force: :cascade do |t|
    t.string "type"
    t.integer "user_id", null: false
    t.integer "message_type", null: false
    t.integer "delivery_type", null: false
    t.string "subjectable_type"
    t.integer "subjectable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subjectable_type", "subjectable_id"], name: "index_notifications_on_subjectable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.boolean "archived", default: false
    t.integer "archived_by_id"
    t.datetime "archived_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_by_id"], name: "index_products_on_archived_by_id"
    t.index ["name"], name: "index_products_on_name", unique: true
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "records", force: :cascade do |t|
    t.integer "category", default: 0
    t.float "unit_price", null: false
    t.integer "quantity"
    t.integer "variant_id"
    t.integer "user_id", null: false
    t.integer "status", default: 0
    t.integer "service_item_id"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_records_on_customer_id"
    t.index ["service_item_id"], name: "index_records_on_service_item_id"
    t.index ["user_id"], name: "index_records_on_user_id"
    t.index ["variant_id"], name: "index_records_on_variant_id"
  end

  create_table "service_items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_service_items_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address"
    t.string "password_digest", null: false
    t.string "full_name"
    t.string "telephone"
    t.integer "role", default: 0
    t.boolean "is_deleted", default: false
    t.text "settings", default: "{}"
    t.integer "supplier_id"
    t.integer "invited_by_id"
    t.datetime "invited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["supplier_id"], name: "index_users_on_supplier_id"
    t.index ["telephone"], name: "index_users_on_telephone", unique: true
  end

  create_table "variants", force: :cascade do |t|
    t.string "name"
    t.float "supply_price"
    t.float "buying_price"
    t.integer "quantity", default: 0
    t.integer "product_id", null: false
    t.integer "previous_quantity"
    t.integer "stock_threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "product_id"], name: "index_variants_on_name_and_product_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "products", "users"
  add_foreign_key "records", "users"
  add_foreign_key "service_items", "users"
  add_foreign_key "sessions", "users"
end
