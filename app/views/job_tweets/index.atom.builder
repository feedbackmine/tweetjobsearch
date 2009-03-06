atom_feed do |feed|
  feed.title "tweetjobsearch" 
  feed.updated @tweets.first.created_at
  @tweets.each do |tweet|
  
    feed.entry(tweet, 
               :id => tweet.status_id, 
               :url => "http://twitter.com/#{tweet.screen_name}/statuses/#{tweet.status_id}") do |entry|
      entry.title     tweet.text
      entry.published tweet.created_at
      entry.content   tweet.text, :type => 'html'
      entry.updated   tweet.created_at
      entry.link      :type => "image/png", :rel => "image", :href => tweet.profile_image_url
      entry.author do |author|
        author.name  "#{tweet.screen_name} (#{tweet.name})"
        author.uri   "http://twitter.com/#{tweet.screen_name}"
      end
    end
  end
end
