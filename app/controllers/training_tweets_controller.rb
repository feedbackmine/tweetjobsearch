class TrainingTweetsController < ApplicationController
  before_filter :require_user
  
  def index
    if params[:q].blank?
      @tweets = TrainingTweet.paginate :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    else
      @tweets = TrainingTweet.search params[:q], :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    end
  end
  
  def create
    tweet = Tweet.find_by_status_id(params[:status_id])
    if params[:label] == "1"  
      Tweet.delete_all("status_id = #{tweet.status_id}")
      attributes = tweet.attributes
      attributes["reason"] = JobTweet::MANUAL
      JobTweet.create(attributes)
    end
    TrainingTweet.create(:status_id => params[:status_id],
                          :screen_name => tweet.screen_name, 
                          :text => tweet.text,
                          :language => tweet.language, 
                          :label => params[:label])
    redirect_to :action => 'index'
  end
  
  def destroy
    TrainingTweet.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
