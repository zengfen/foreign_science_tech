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

ActiveRecord::Schema.define(version: 20200716120617) do

  create_table "author_counters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "con_author", limit: 150
    t.integer "count",                  default: 0, null: false
    t.date    "con_date"
    t.index ["con_author"], name: "index_author_counters_on_con_author", using: :btree
    t.index ["con_date"], name: "index_author_counters_on_con_date", using: :btree
  end

  create_table "author_counters_test", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "con_author", limit: 100
    t.integer "count",                  default: 0, null: false
    t.date    "con_date"
    t.index ["con_author"], name: "index_author_counters_on_con_author", using: :btree
    t.index ["con_date"], name: "index_author_counters_on_con_date", using: :btree
  end

  create_table "spider_tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "spider_id"
    t.integer  "level",                                  default: 1
    t.text     "full_keywords",         limit: 16777215
    t.integer  "status",                                 default: 0
    t.integer  "task_type",                              default: 1
    t.integer  "current_task_count",                     default: 0,  null: false
    t.integer  "current_success_count",                  default: 0,  null: false
    t.integer  "current_fail_count",                     default: 0,  null: false
    t.integer  "current_result_count",                   default: 0,  null: false
    t.integer  "timeout_second",                         default: 15, null: false
    t.string   "special_tag_names"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.index ["spider_id"], name: "spider_id", using: :btree
    t.index ["task_type"], name: "st_tt", using: :btree
  end

  create_table "spiders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "spider_name",      limit: 50
    t.string   "name_cn"
    t.string   "name_en"
    t.integer  "status",                      default: 0
    t.integer  "real_time_status",            default: 0
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.datetime "next_time"
    t.index ["spider_name"], name: "index_spiders_on_spider_name", unique: true, using: :btree
  end

  create_table "subtasks", id: :string, limit: 32, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "task_id"
    t.integer "status",        limit: 1,     default: 0
    t.integer "cycle_status",  limit: 1
    t.text    "content",       limit: 65535
    t.text    "error_content", limit: 65535
    t.bigint  "error_at"
    t.bigint  "competed_at"
    t.integer "error_code"
    t.index ["task_id", "status"], name: "ts", using: :btree
    t.index ["task_id"], name: "index_subtasks_on_task_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",           limit: 50
    t.string   "name"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["email"], name: "user_email", unique: true, using: :btree
  end

end
