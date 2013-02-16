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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130216103308) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "languages", ["name"], :name => "index_languages_on_name", :unique => true

  create_table "links", :force => true do |t|
    t.integer  "word1_id"
    t.integer  "word2_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "owner_id"
  end

  add_index "links", ["word1_id"], :name => "index_links_on_word1_id"
  add_index "links", ["word2_id"], :name => "index_links_on_word2_id"

  create_table "registrations", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "name_src_id"
    t.integer  "email_src_id"
    t.string   "remember_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "words", :force => true do |t|
    t.string   "content"
    t.integer  "language_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "link_id"
    t.integer  "owner_id"
  end

  add_index "words", ["content"], :name => "index_words_on_content"
  add_index "words", ["language_id"], :name => "index_words_on_language_id"

end
