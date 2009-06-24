class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.integer :status_id, :limit => 8
      t.text    :text
      t.string  :source
      t.boolean :truncated
      t.integer :in_reply_to_status_id, :limit => 8
      t.integer :in_reply_to_user_id, :limit => 8
      t.boolean :favorited

      t.integer :user_id
      t.string  :name
      t.string  :screen_name  
      t.string  :description
      t.string  :location
      t.string  :profile_image_url
      t.string  :url
      t.boolean :protected
      t.integer :followers_count

      t.timestamps
    end
    
    create_table :job_tweets do |t|
      t.integer :status_id, :limit => 8
      t.text    :text
      t.string  :source
      t.boolean :truncated
      t.integer :in_reply_to_status_id, :limit => 8
      t.integer :in_reply_to_user_id, :limit => 8
      t.boolean :favorited

      t.integer :user_id
      t.string  :name
      t.string  :screen_name  
      t.string  :description
      t.string  :location
      t.string  :profile_image_url
      t.string  :url
      t.boolean :protected
      t.integer :followers_count
      
      t.timestamps
    end
    
    create_table :training_tweets do |t|
      t.integer :status_id, :limit => 8
      t.string  :screen_name
      t.text    :text
      t.integer :label

      t.timestamps
    end
    
    add_index :tweets, :status_id, :unique => true
    add_index :job_tweets, :status_id, :unique => true
    add_index :training_tweets, :status_id, :unique => true
  end

  def self.down
    drop_table :tweets
    drop_table :job_tweets
    drop_table :training_tweets
  end
end
