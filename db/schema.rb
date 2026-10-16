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

ActiveRecord::Schema[8.1].define(version: 2026_10_15_000003) do
  create_table "build_items", force: :cascade do |t|
    t.integer "build_id", null: false
    t.integer "component_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["build_id", "component_id"], name: "index_build_items_on_build_id_and_component_id", unique: true
    t.index ["build_id"], name: "index_build_items_on_build_id"
    t.index ["component_id"], name: "index_build_items_on_component_id"
  end

  create_table "builds", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "purpose", null: false
    t.string "platform", default: "x86-64", null: false
    t.string "status", default: "draft", null: false
    t.integer "budget_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_builds_on_status"
    t.index ["user_id", "created_at"], name: "index_builds_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_builds_on_user_id"
  end

  create_table "compatibility_rules", force: :cascade do |t|
    t.integer "component_id", null: false
    t.integer "compatible_component_id", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compatible_component_id"], name: "index_compatibility_rules_on_compatible_component_id"
    t.index ["component_id", "compatible_component_id"], name: "index_compatibility_rules_on_component_pair", unique: true
    t.index ["component_id"], name: "index_compatibility_rules_on_component_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "name", null: false
    t.string "manufacturer", null: false
    t.string "category", null: false
    t.string "platform", default: "x86-64", null: false
    t.string "socket"
    t.integer "price_cents", default: 0, null: false
    t.integer "power_watts"
    t.integer "memory_gb"
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_components_on_category"
    t.index ["manufacturer", "name"], name: "index_components_on_manufacturer_and_name", unique: true
    t.index ["platform"], name: "index_components_on_platform"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "LOWER(email)", name: "index_users_on_lower_email", unique: true
  end

  add_foreign_key "build_items", "builds"
  add_foreign_key "build_items", "components"
  add_foreign_key "builds", "users"
  add_foreign_key "compatibility_rules", "components"
  add_foreign_key "compatibility_rules", "components", column: "compatible_component_id"
end
