# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090304052542) do

  create_table "job_tweets", :force => true do |t|
    t.integer  "status_id"
    t.text     "text"
    t.string   "source"
    t.boolean  "truncated"
    t.integer  "in_reply_to_status_id"
    t.integer  "in_reply_to_user_id"
    t.boolean  "favorited"
    t.integer  "user_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "description"
    t.string   "location"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.integer  "followers_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta"
    t.string   "language"
    t.integer  "reason"
  end

  add_index "job_tweets", ["created_at"], :name => "index_job_tweets_on_created_at"
  add_index "job_tweets", ["status_id"], :name => "index_job_tweets_on_status_id", :unique => true

  create_table "training_tweets", :force => true do |t|
    t.integer  "status_id"
    t.string   "screen_name"
    t.text     "text"
    t.integer  "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta"
    t.string   "language"
  end

  add_index "training_tweets", ["created_at"], :name => "index_training_tweets_on_created_at"
  add_index "training_tweets", ["status_id"], :name => "index_training_tweets_on_status_id", :unique => true

  create_table "tweets", :force => true do |t|
    t.integer  "status_id"
    t.text     "text"
    t.string   "source"
    t.boolean  "truncated"
    t.integer  "in_reply_to_status_id"
    t.integer  "in_reply_to_user_id"
    t.boolean  "favorited"
    t.integer  "user_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "description"
    t.string   "location"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.integer  "followers_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta"
    t.string   "language"
  end

  add_index "tweets", ["created_at"], :name => "index_tweets_on_created_at"
  add_index "tweets", ["status_id"], :name => "index_tweets_on_status_id", :unique => true

end
