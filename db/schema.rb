# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160311113344) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "areas", force: :cascade do |t|
    t.string   "name",       null: false
    t.float    "latitude",   null: false
    t.float    "longitude",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "country"
  end

  add_index "areas", ["name"], name: "index_areas_on_name", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", using: :btree

  create_table "categories_memories", force: :cascade do |t|
    t.integer "category_id"
    t.integer "memory_id"
  end

  create_table "home_pages", force: :cascade do |t|
    t.integer  "featured_memory_id",                            null: false
    t.integer  "featured_scrapbook_id",                         null: false
    t.string   "featured_scrapbook_memory_ids",                 null: false
    t.boolean  "published",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hero_image"
  end

  create_table "links", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memories", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "type"
    t.string   "source"
    t.text     "description"
    t.string   "year"
    t.string   "month"
    t.string   "day"
    t.string   "attribution"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_id"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "moderation_state"
    t.string   "moderation_reason"
    t.datetime "last_moderated_at"
    t.integer  "moderated_by_id"
  end

  create_table "moderation_logs", force: :cascade do |t|
    t.integer  "moderatable_id",   null: false
    t.string   "moderatable_type", null: false
    t.string   "from_state",       null: false
    t.string   "to_state",         null: false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "moderated_by_id"
  end

  create_table "scrapbook_memories", force: :cascade do |t|
    t.integer  "scrapbook_id"
    t.integer  "memory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
  end

  add_index "scrapbook_memories", ["memory_id"], name: "index_scrapbook_memories_on_memory_id", using: :btree
  add_index "scrapbook_memories", ["scrapbook_id"], name: "index_scrapbook_memories_on_scrapbook_id", using: :btree

  create_table "scrapbooks", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",             null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "moderation_state"
    t.string   "moderation_reason"
    t.datetime "last_moderated_at"
    t.integer  "moderated_by_id"
  end

  add_index "scrapbooks", ["user_id"], name: "index_scrapbooks_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "memory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["memory_id"], name: "index_taggings_on_memory_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "temp_images", force: :cascade do |t|
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                                      null: false
    t.string   "last_name"
    t.string   "email",                                           null: false
    t.string   "crypted_password",                                null: false
    t.string   "salt",                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "screen_name"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.boolean  "is_group",                        default: false
    t.boolean  "is_admin",                        default: false
    t.boolean  "accepted_t_and_c"
    t.text     "description"
    t.string   "avatar"
    t.string   "moderation_state"
    t.integer  "moderated_by_id"
    t.string   "moderation_reason"
    t.datetime "last_moderated_at"
    t.boolean  "hide_getting_started"
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

end
