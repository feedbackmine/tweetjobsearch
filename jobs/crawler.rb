#!/usr/bin/env ./script/runner

require 'rubygems'
require 'uri'
require 'yajl/http_stream'
require 'logger'
require 'language_detector'
require 'ar-extensions/adapters/mysql'
require 'ar-extensions/import/mysql'
require File.dirname(__FILE__) + '/classifier.rb'

class Crawler
  
  TRUSTED_SOURCES = %w{
      AtlantaTechJobs
      ATX_Jobs
      computer_jobs 
      chicagowebjobs
      eComjobs
      GetCasinoJobs
      ITJobsMelbourne
      ITJobsSydney
      IsleCasinoJobs
      JustTechJobs
      jobnoggin
      jobs4bloggers
      jobs_at_Account
      jobs_at_retail
      jobs_sf_skilled
      jobs_at_food
      jobs_at_Edu
      jobs_at_writing
      jobs_at_health
      jobs_DC_beauty
      jobs_DC_clerk
      jobs_DC_CSR
      jobs_DC_DBA
      jobs_DC_food
      jobs_DC_GL
      jobs_DC_skilled
      jobs_DC_NetAdmn
      #jobs_in_media
      jobs_ny_edu
      jobs_NY_Legal
      jobs_NY_beauty
      jobs_NY_np
      jobs_sat_Accoun
      jobs_sat_CSR
      jobs_sat_beauty
      jobs_sat_bus
      jobs_sat_health
      jobs_sat_food
      jobs_sat_sales
      jobs_sat_retail
      Jobs_SF_art
      jobs_sf_retail
      jobs_sat_DBA
      jobs_ny_edu
      jobs_ny_enginee
      jobs_ny_hr
      jobs_NY_writing
      jobs_NY_real
      JobMotel_Ruby
      Joblighted
      journalism_jobs
      LAMPJobs
      LAMPContracts
      MaddisonRecruit
      marketingjob
      media_jobs
      MediaJobsNYC
      MTLtweetjobs
      mtvnetworksjobs
      myitjobs
      nymarketingjobs
      NewYorkTechJobs
      phoenixtechjobs
      phppositions
      #publishingjobs
      RailsJobs
      ReddingJobs
      SocialMediaJob
      seojobs     
      SoCalLawCareers
      TopJobsInLondon
      wahm_job_leads
      Web_Design_Jobs
      WebJob
      vegascasinojobs
  }
  
  UNTRUSTED_SOURCES = %w{
      hknews_local
      hknews_world
      etipos_greece
      finance_news
      freephptutorial
  }
              
  JOB_COLUMNS = [:created_at,
              :status_id,
              :text,
              :source,
              :truncated,
              :in_reply_to_status_id,
              :in_reply_to_user_id,
              :favorited,
              
              :user_id,
              :name,
              :screen_name,
              :description,
              :location,
              :profile_image_url,
              :url,
              :protected,
              :followers_count,
              
              :language,
              :reason]
              
  CLASSIFIER_FILE = File.join(File.dirname(__FILE__), '../job.model')
          
  def initialize
    @classifier = Classifier.load
    @mtime_of_classifier = File.mtime(CLASSIFIER_FILE) if File.exist?(CLASSIFIER_FILE)
    @logger = Logger.new('log/crawler.log')
    @trusted_sources = {} 
    TRUSTED_SOURCES.each {|s| @trusted_sources[s] = true}
    @untrusted_sources = {}
    UNTRUSTED_SOURCES.each {|s| @untrusted_sources[s] = true}
    @language_detector = LanguageDetector.new
  end
  
  def run(username, password)
    job_tweets = []
    count = 0
    
    @logger.info "#{Time.now.to_s} started"
    
    uri = URI.parse("http://#{username}:#{password}@stream.twitter.com/spritzer.json")
    Yajl::HttpStream.get(uri) do |status|
      #puts status.inspect
      count += 1
      parse(status, job_tweets)
      
      if count > 1000
        @logger.info "#{Time.now.to_s} #{job_tweets.size} found"
        JobTweet.import(JOB_COLUMNS, job_tweets, {:validate => false, :timestamps => false, :ignore => true}) unless job_tweets.empty?
        job_tweets = []
        count = 0
        
        exit_if_needed
        reload_classifier_if_needed
      end
      
    end
    
  rescue Exception => e
    puts e
    puts e.backtrace.join("\n")
    @logger.info e.message
    @logger.info e.backtrace.join("\n")
  end
  
private
  def exit_if_needed
    if File.exist? '/tmp/restart-crawler.txt'
      File.delete '/tmp/restart-crawler.txt'
      @logger.info 'crawler exit'
      exit
    end
  end
  
  def reload_classifier_if_needed
    mtime_of_classifier = File.mtime(CLASSIFIER_FILE) if File.exist?(CLASSIFIER_FILE)
    if (mtime_of_classifier != @mtime_of_classifier)
      @classifier = Classifier.load
      @mtime_of_classifier = mtime_of_classifier
      @logger.info 'classifer reloaded'
    end
  end

  def is_trusted_source?(screen_name)
    #ydliu #hiring 
    #rtjobs
    #jobFeedr
    
    if @trusted_sources.key? screen_name
      return true
    else
      return false
    end
  end

  def is_job_tweet?(text, screen_name)
    if !@classifier
      return false
    elsif @untrusted_sources.key? screen_name
      return false
    else
      return @classifier.predict(text) == 1
    end
  end

  def parse(status, job_tweets)
    #http://groups.google.com/group/twitter-development-talk/browse_thread/thread/9e05fa281cc3afee/8df74b0597e95482?lnk=gst&q=deletion#8df74b0597e95482
    return if status["created_at"].blank?
    
    created_at = Time.zone.parse(status["created_at"])
    status_id = status["id"].to_i
    text = status["text"]
    source = status["source"]
    truncated = status["truncated"]
    in_reply_to_status_id = status["in_reply_to_status_id"].to_i
    in_reply_to_user_id = status["in_reply_to_user_id"].to_i
    favorited = status["favorited"]

    user = status["user"]
    user_id = user["id"].to_i
    name = user["name"]
    screen_name = user["screen_name"]
    description = user["description"]
    location = user["location"]
    profile_image_url = user["profile_image_url"]
    url = user["url"]
    user_protected = user["protected"]
    followers_count = user["followers_count"].to_i

    tweet = [created_at,
              status_id,
              text,
              source,
              (truncated == "true"),
              in_reply_to_status_id,
              in_reply_to_user_id,
              (favorited == "true"),
              
              user_id,
              name,
              screen_name,
              description,
              location,
              profile_image_url,
              url,
              (user_protected == "true"),
              followers_count,
              
              @language_detector.detect(text)]
       
    if is_trusted_source?(screen_name)
      tweet << JobTweet::TRUSTED
      job_tweets.push tweet
    elsif is_job_tweet?(text, screen_name)
      tweet << JobTweet::CLASSIFIER
      job_tweets.push tweet
    end
    
    return status_id
  end
end

crawler = Crawler.new
crawler.run("feedbackmine2", 'feedbackmine2password')

