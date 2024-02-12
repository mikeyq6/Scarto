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

ActiveRecord::Schema.define(version: 2024_02_12_144035) do

  create_table "game_players", force: :cascade do |t|
    t.integer "game_id"
    t.string "name"
    t.decimal "player_type"
    t.decimal "ai_level"
    t.index ["game_id"], name: "index_game_players_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "firstname"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state"
    t.string "status"
  end

end
