class TrainingTweet < ActiveRecord::Base
  define_index do
    indexes text
    has created_at
    set_property :delta => true
  end
end
