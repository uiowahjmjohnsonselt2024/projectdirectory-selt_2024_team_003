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

ActiveRecord::Schema[8.0].define(version: 2024_12_02_011958) do
  create_table "enemies", force: :cascade do |t|
    t.string "name"
    t.integer "health", default: 300
    t.integer "attack", default: 20
    t.integer "defense", default: 10
    t.integer "iq", default: 5
    t.integer "game_id"
    t.integer "x_position"
    t.integer "y_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_health", default: 300
    t.integer "level", default: 0
    t.integer "special_attack"
    t.integer "special_defense"
    t.integer "mana"
    t.integer "max_mana"
    t.index ["game_id"], name: "index_enemies_on_game_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "game_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.integer "x_position", default: 0
    t.integer "y_position", default: 0
    t.integer "health", default: 100
    t.integer "level", default: 1
    t.integer "mana"
    t.index ["game_id"], name: "index_game_users_on_game_id"
    t.index ["user_id"], name: "index_game_users_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "user_id", null: false
    t.integer "recipient_id", null: false
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "moves", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "mana_cost"
    t.integer "health_cost"
    t.integer "damage"
    t.string "effect_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_moves", force: :cascade do |t|
    t.integer "user_id"
    t.integer "move_id"
    t.integer "usage_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_user_moves_on_move_id"
    t.index ["user_id"], name: "index_user_moves_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.integer "health", default: 100
    t.integer "attack", default: 10
    t.integer "defense", default: 5
    t.integer "iq", default: 1
    t.string "archetype"
    t.integer "level", default: 1
    t.integer "experience", default: 0
    t.integer "mana"
    t.integer "special_attack"
    t.integer "special_defense"
  end

  add_foreign_key "enemies", "games"
  add_foreign_key "messages", "users"
  add_foreign_key "user_moves", "moves"
  add_foreign_key "user_moves", "users"
end
