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

ActiveRecord::Schema.define(version: 20130822154326) do

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inclusions", force: true do |t|
    t.integer  "list_id"
    t.integer  "word_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inclusions", ["list_id"], name: "index_inclusions_on_list_id"

  create_table "languages", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["name"], name: "index_languages_on_name", unique: true

  create_table "links", force: true do |t|
    t.integer  "word1_id"
    t.integer  "word2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  add_index "links", ["word1_id"], name: "index_links_on_word1_id"
  add_index "links", ["word2_id"], name: "index_links_on_word2_id"

  create_table "lists", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lists", ["owner_id"], name: "index_lists_on_owner_id"
  add_index "lists", ["parent_id"], name: "index_lists_on_parent_id"

  create_table "registrations", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trains", force: true do |t|
    t.integer  "user_id"
    t.integer  "word_id"
    t.string   "guess"
    t.boolean  "success"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trains", ["user_id"], name: "index_trains_on_user_id"
  add_index "trains", ["word_id"], name: "index_trains_on_word_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "words", force: true do |t|
    t.string   "content"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "link_id"
    t.integer  "owner_id"
  end

  add_index "words", ["content"], name: "index_words_on_content"
  add_index "words", ["language_id"], name: "index_words_on_language_id"

end
