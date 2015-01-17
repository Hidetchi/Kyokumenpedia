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

ActiveRecord::Schema.define(version: 20150117200645) do

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "appearances", force: true do |t|
    t.integer "game_id"
    t.integer "position_id"
    t.integer "num"
    t.integer "next_move_id"
  end

  add_index "appearances", ["position_id"], name: "index_appearances_on_position_id", using: :btree

  create_table "books", force: true do |t|
    t.string   "isbn13"
    t.string   "title"
    t.string   "author"
    t.string   "publisher"
    t.date     "publication_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["isbn13"], name: "index_books_on_isbn13", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "discussions", force: true do |t|
    t.integer  "position_id"
    t.integer  "user_id"
    t.text     "content"
    t.integer  "num"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discussions", ["created_at"], name: "index_discussions_on_created_at", using: :btree
  add_index "discussions", ["position_id"], name: "index_discussions_on_position_id", using: :btree

  create_table "editor_pickups", force: true do |t|
    t.integer  "position_id"
    t.integer  "user_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.boolean  "check_all",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true, using: :btree

  create_table "game_sources", force: true do |t|
    t.string   "name"
    t.string   "pass"
    t.string   "kifu_url_header"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category"
    t.string   "kifu_url_footer", default: ""
  end

  create_table "games", force: true do |t|
    t.string   "black_name"
    t.string   "white_name"
    t.integer  "black_rate"
    t.integer  "white_rate"
    t.date     "date"
    t.integer  "result"
    t.string   "native_kid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "handicap_id"
    t.text     "csa"
    t.integer  "game_source_id"
    t.string   "csa_hash"
    t.boolean  "relation_updated", default: false
    t.string   "event"
  end

  add_index "games", ["csa_hash"], name: "index_games_on_csa_hash", unique: true, using: :btree

  create_table "handicaps", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "headlines", force: true do |t|
    t.string   "name"
    t.integer  "position_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "headlines", ["name"], name: "index_headlines_on_name", unique: true, using: :btree

  create_table "moves", force: true do |t|
    t.integer  "prev_position_id"
    t.integer  "next_position_id"
    t.string   "csa"
    t.boolean  "promote",          default: false
    t.boolean  "vague",            default: false
    t.integer  "stat1_total",      default: 0
    t.integer  "stat2_total",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "capture",          default: false
    t.integer  "stat3_total",      default: 0
  end

  add_index "moves", ["next_position_id"], name: "index_moves_on_next_position_id", using: :btree
  add_index "moves", ["prev_position_id"], name: "index_moves_on_prev_position_id", using: :btree

  create_table "positions", force: true do |t|
    t.string   "sfen"
    t.integer  "handicap_id"
    t.integer  "strategy_id"
    t.integer  "stat1_black",    default: 0
    t.integer  "stat1_white",    default: 0
    t.integer  "stat1_draw",     default: 0
    t.integer  "stat2_black",    default: 0
    t.integer  "stat2_white",    default: 0
    t.integer  "stat2_draw",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "latest_post_id"
    t.integer  "views",          default: 0
    t.integer  "stat3_black",    default: 0
    t.integer  "stat3_white",    default: 0
    t.integer  "stat3_draw",     default: 0
  end

  add_index "positions", ["sfen"], name: "index_positions_on_sfen", length: {"sfen"=>96}, using: :btree
  add_index "positions", ["views"], name: "index_positions_on_views", using: :btree

  create_table "rs_evaluations", force: true do |t|
    t.string   "reputation_name"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.float    "value",           limit: 24, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data"
  end

  add_index "rs_evaluations", ["reputation_name", "source_id", "source_type", "target_id", "target_type"], name: "index_rs_evaluations_on_reputation_name_and_source_and_target", unique: true, using: :btree
  add_index "rs_evaluations", ["reputation_name"], name: "index_rs_evaluations_on_reputation_name", using: :btree
  add_index "rs_evaluations", ["source_id", "source_type"], name: "index_rs_evaluations_on_source_id_and_source_type", using: :btree
  add_index "rs_evaluations", ["target_id", "target_type"], name: "index_rs_evaluations_on_target_id_and_target_type", using: :btree

  create_table "rs_reputation_messages", force: true do |t|
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "receiver_id"
    t.float    "weight",      limit: 24, default: 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rs_reputation_messages", ["receiver_id", "sender_id", "sender_type"], name: "index_rs_reputation_messages_on_receiver_id_and_sender", unique: true, using: :btree
  add_index "rs_reputation_messages", ["receiver_id"], name: "index_rs_reputation_messages_on_receiver_id", using: :btree
  add_index "rs_reputation_messages", ["sender_id", "sender_type"], name: "index_rs_reputation_messages_on_sender_id_and_sender_type", using: :btree

  create_table "rs_reputations", force: true do |t|
    t.string   "reputation_name"
    t.float    "value",           limit: 24, default: 0.0
    t.string   "aggregated_by"
    t.integer  "target_id"
    t.string   "target_type"
    t.boolean  "active",                     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data"
  end

  add_index "rs_reputations", ["reputation_name", "target_id", "target_type"], name: "index_rs_reputations_on_reputation_name_and_target", unique: true, using: :btree
  add_index "rs_reputations", ["reputation_name"], name: "index_rs_reputations_on_reputation_name", using: :btree
  add_index "rs_reputations", ["target_id", "target_type"], name: "index_rs_reputations_on_target_id_and_target_type", using: :btree

  create_table "simple_captcha_data", force: true do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "strategies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.integer  "main_position_id"
  end

  add_index "strategies", ["ancestry"], name: "index_strategies_on_ancestry", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "strength"
    t.string   "style"
    t.string   "url"
    t.string   "description"
    t.integer  "point",                  default: 0
    t.string   "name81"
    t.boolean  "receive_watching",       default: true
    t.boolean  "receive_following",      default: true
    t.integer  "role",                   default: 0
    t.integer  "card",                   default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["point"], name: "index_users_on_point", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "watches", force: true do |t|
    t.integer  "user_id"
    t.integer  "position_id"
    t.boolean  "check_all",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "watches", ["position_id"], name: "index_watches_on_position_id", using: :btree
  add_index "watches", ["user_id", "position_id"], name: "index_watches_on_user_id_and_position_id", unique: true, using: :btree
  add_index "watches", ["user_id"], name: "index_watches_on_user_id", using: :btree

  create_table "wikiposts", force: true do |t|
    t.integer  "position_id"
    t.integer  "user_id"
    t.text     "content"
    t.string   "comment"
    t.boolean  "minor"
    t.integer  "prev_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "adds"
    t.integer  "dels"
    t.integer  "likes",        default: 0
  end

  add_index "wikiposts", ["position_id"], name: "index_wikiposts_on_position_id", using: :btree
  add_index "wikiposts", ["user_id"], name: "index_wikiposts_on_user_id", using: :btree

end
