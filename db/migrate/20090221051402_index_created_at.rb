class IndexCreatedAt < ActiveRecord::Migration
  def self.up
    add_index :tweets,          :created_at
    add_index :job_tweets,      :created_at
    add_index :training_tweets, :created_at
  end

  def self.down
    remove_index :tweets,          :created_at
    remove_index :job_tweets,      :created_at
    remove_index :training_tweets, :created_at
  end
end
