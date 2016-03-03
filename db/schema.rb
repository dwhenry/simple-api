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

ActiveRecord::Schema.define(version: 20160302082944) do

  create_table "games", force: :cascade do |t|
    t.string   "uuid"
    t.string   "state"
    t.integer  "winner_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "max_players"
  end

  add_index "games", ["winner_id"], name: "index_games_on_winner_id"

  create_table "players", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "players", ["game_id"], name: "index_players_on_game_id"
  add_index "players", ["user_id"], name: "index_players_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "password"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "auth_token"
    t.datetime "auth_token_valid_until"
  end

end
