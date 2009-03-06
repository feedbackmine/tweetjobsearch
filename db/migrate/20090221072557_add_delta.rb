class AddDelta < ActiveRecord::Migration
  def self.up
    add_column :tweets,          :delta, :boolean
    add_column :job_tweets,      :delta, :boolean
    add_column :training_tweets, :delta, :boolean
  end

  def self.down
    remove_column :tweets,          :delta
    remove_column :job_tweets,      :delta
    remove_column :training_tweets, :delta
  end
end
