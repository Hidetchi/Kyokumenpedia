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

ActiveRecord::Schema.define(version: 20141020155126) do

  create_table "appearances", force: true do |t|
    t.integer  "game_id"
    t.integer  "position_id"
    t.integer  "num"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "next_move_id"
  end

  add_index "appearances", ["game_id"], name: "index_appearances_on_game_id"
  add_index "appearances", ["position_id"], name: "index_appearances_on_position_id"

  create_table "game_sources", force: true do |t|
    t.string   "name"
    t.string   "pass"
    t.string   "kifu_url_header"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category"
  end

  create_table "games", force: true do |t|
    t.string   "black_name"
    t.string   "white_name"
    t.integer  "black_rate"
    t.integer  "white_rate"
    t.date     "date"
    t.integer  "result"
    t.integer  "native_kid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "handicap_id"
    t.text     "csa"
    t.integer  "game_source_id"
  end

  add_index "games", ["csa"], name: "index_games_on_csa", unique: true

  create_table "handicaps", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  create_table "positions", force: true do |t|
    t.string   "sfen"
    t.text     "csa"
    t.integer  "handicap_id"
    t.integer  "strategy_id"
    t.integer  "stat1_black", default: 0
    t.integer  "stat1_white", default: 0
    t.integer  "stat1_draw",  default: 0
    t.integer  "stat2_black", default: 0
    t.integer  "stat2_white", default: 0
    t.integer  "stat2_draw",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "strategies", force: true do |t|
    t.string   "name"
    t.integer  "parent_strategy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
