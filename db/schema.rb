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

ActiveRecord::Schema.define(version: 20150930194824) do

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_memberships", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "admin",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_memberships", ["group_id", "user_id"], name: "index_group_memberships_on_group_id_and_user_id", unique: true
  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id"
  add_index "group_memberships", ["user_id"], name: "index_group_memberships_on_user_id"

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "faker_id"
    t.boolean  "public"
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

  create_table "link_votes", force: true do |t|
    t.integer  "link_id"
    t.integer  "user_id"
    t.boolean  "pro"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "link_votes", ["link_id"], name: "index_link_votes_on_link_id"
  add_index "link_votes", ["user_id"], name: "index_link_votes_on_user_id"

  create_table "links", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "word_id"
    t.integer  "meaning_id"
    t.integer  "pro",        default: 0
    t.integer  "contra",     default: 0
  end

  add_index "links", ["meaning_id"], name: "index_links_on_meaning_id"
  add_index "links", ["word_id"], name: "index_links_on_word_id"

  create_table "lists", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language1_id"
    t.integer  "language2_id"
    t.integer  "public_level", default: 0
  end

  add_index "lists", ["owner_id"], name: "index_lists_on_owner_id"
  add_index "lists", ["parent_id"], name: "index_lists_on_parent_id"
  add_index "lists", ["public_level"], name: "index_lists_on_public_level"

  create_table "meanings", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "train_fragments", force: true do |t|
    t.integer  "train_id"
    t.integer  "word_set_id"
    t.integer  "sort"
    t.boolean  "q_to_a"
    t.integer  "item1_id"
    t.integer  "item2_id"
    t.string   "answer"
    t.boolean  "is_correct"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "item1_is_word"
    t.boolean  "item2_is_word"
    t.integer  "language1_id"
    t.integer  "language2_id"
  end

  create_table "trains", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "list_id"
    t.boolean  "finished"
    t.float    "success_ratio"
    t.integer  "max"
    t.integer  "type_of_train"
    t.integer  "error_policy"
    t.boolean  "include_sub_lists"
    t.text     "fragments_list"
    t.integer  "fragment_pos"
    t.integer  "q_to_a"
    t.boolean  "finalized"
  end

  add_index "trains", ["list_id"], name: "index_trains_on_list_id"
  add_index "trains", ["user_id"], name: "index_trains_on_user_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.boolean  "faker"
    t.integer  "faker_for_group"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "word_sets", force: true do |t|
    t.integer  "word_id"
    t.integer  "meaning_id"
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "asked_qa"
    t.integer  "success_qa"
    t.float    "success_ratio_qa"
    t.float    "asked_aq"
    t.float    "success_aq"
    t.float    "success_ratio_aq"
  end

  add_index "word_sets", ["list_id"], name: "index_word_sets_on_list_id"
  add_index "word_sets", ["user_id"], name: "index_word_sets_on_user_id"

  create_table "words", force: true do |t|
    t.string   "content"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  add_index "words", ["content"], name: "index_words_on_content"
  add_index "words", ["language_id"], name: "index_words_on_language_id"

end
