#!/usr/bin/env ./script/runner

require 'rubygems'
require 'nokogiri'
require 'open-uri'
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
      ITJobsMelbourne
      ITJobsSydney
      JustTechJobs
      jobnoggin
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
      LAMPJobs
      LAMPContracts
      MaddisonRecruit
      marketingjob
      nymarketingjobs
      NewYorkTechJobs
      phoenixtechjobs
      phppositions
      RailsJobs
      ReddingJobs
      SocialMediaJob
      seojobs     
      SoCalLawCareers
      TopJobsInLondon
      wahm_job_leads
      Web_Design_Jobs
      WebJob
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
              
  CLASSIFIER_FILE = File.join(File.dirname(__FILE__), '../job.classifier')
          
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
  
  def run(start_time)
    exit_if_needed
    reload_classifier_if_needed
  
    count = 0
    min_id = 0
    max_id = 0
    job_tweets = []
    @logger.info "new round started: " + start_time.to_s
    
    begin
      xml = open("http://twitter.com/statuses/public_timeline_partners_nrab481.xml")
      fetch_time = Time.now

      doc = Nokogiri::XML(xml).xpath("//status").each do |status|
        count += 1
        status_id = parse(status, job_tweets)
        min_id = status_id if status_id < min_id or min_id == 0
        max_id = status_id if status_id > max_id or max_id == 0
      end
      parse_time = Time.now
      
      JobTweet.import(JOB_COLUMNS, job_tweets, {:validate => false, :timestamps => false, :ignore => true}) unless job_tweets.empty?
      end_time = Time.now
      
      @logger.info count.to_s + ' messages (' + min_id.to_s + '-' + max_id.to_s + 
        '), fetch time: ' + (fetch_time - start_time).to_s +
        ', parse time: ' + (parse_time - fetch_time).to_s +
        ', db time: ' + (end_time - fetch_time).to_s  
        
      return end_time   
    rescue Exception => e
      puts e
      @logger.info e.message
      @logger.info e.backtrace.join("\n")
      return Time.now
    end
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
    created_at = Time.zone.parse(status.at("./created_at").content)
    status_id = status.at("./id").content.to_i
    text = status.at("./text").content
    source = status.at("./source").content rescue nil
    truncated = status.at("./truncated").content rescue nil
    in_reply_to_status_id = status.at("./in_reply_to_status_id").content.to_i rescue nil
    in_reply_to_user_id = status.at("./in_reply_to_user_id").content.to_i rescue nil
    favorited = status.at("./favorited").content rescue nil

    user = status.at("./user")
    user_id = user.at("./id").content.to_i
    name = user.at("./name").content
    screen_name = user.at("./screen_name").content rescue nil
    description = user.at("./description").content rescue nil
    location = user.at("./location").content rescue nil
    profile_image_url = user.at("./profile_image_url").content rescue nil
    url = user.at("./url").content rescue nil
    user_protected = user.at("./protected").content
    followers_count = user.at("./followers_count").content.to_i

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
loop do
  start_time = Time.now
  end_time = crawler.run(start_time)
  execution_time = end_time - start_time
  sleep(60 - execution_time) unless execution_time >= 60
end
