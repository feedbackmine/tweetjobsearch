class JobTweetsController < ApplicationController
  def index
    if params[:q].blank?
      @tweets = JobTweet.paginate :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    else
      @tweets = JobTweet.search params[:q], :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    end
    
    respond_to do |format|
      format.html 
      format.atom
    end
  end
  
  def edit
    if params[:q].blank?
      @tweets = JobTweet.paginate :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    else
      @tweets = JobTweet.search params[:q], :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    end
  end
  
  def destroy
    tweet = JobTweet.find(params[:id])
    JobTweet.delete_all("status_id = #{tweet.status_id}")
    attributes = tweet.attributes
    attributes.reject! {|k, v| k == 'reason'}
    Tweet.create(attributes)
    TrainingTweet.create(:status_id => tweet.status_id,
                          :screen_name => tweet.screen_name, 
                          :text => tweet.text,
                          :language => tweet.language,
                          :label => 0)
    redirect_to :action => 'edit'
  end
end
