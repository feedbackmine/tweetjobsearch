class AddReasonToJobTweet < ActiveRecord::Migration
  def self.up
    add_column :job_tweets,      :reason, :integer
  end

  def self.down
    remove_column :job_tweets,   :reason
  end
end
