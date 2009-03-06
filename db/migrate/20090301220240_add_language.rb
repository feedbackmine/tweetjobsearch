class AddLanguage < ActiveRecord::Migration
  def self.up
    add_column :tweets,          :language, :string
    add_column :job_tweets,      :language, :string
    add_column :training_tweets, :language, :string
  end

  def self.down
    remove_column :tweets,          :language
    remove_column :job_tweets,      :language
    remove_column :training_tweets, :language
  end
end
