class TweetsController < ApplicationController
  def index
    if params[:q].blank?
      @tweets = Tweet.paginate :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    else
      @tweets = Tweet.search params[:q], :page => params[:page], :per_page => 50, :order => 'created_at DESC'
    end
    
    respond_to do |format|
      format.html 
      format.atom
    end
  end
end
