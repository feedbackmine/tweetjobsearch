TRUSTED_SOURCES = %w{
      AtlantaTechJobs
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
  
@trusted_sources = {} 
TRUSTED_SOURCES.each {|s| @trusted_sources[s] = true}

def brute_force_string_search(str)
  TRUSTED_SOURCES.each {|s|
    return true if s == str
  }
  return false
end

start_time = Time.now
1000.times {
  raise '!' if brute_force_string_search('NoSuchWord')
  raise '!' unless brute_force_string_search('WebJob')
}
puts Time.now - start_time

start_time = Time.now
1000.times {
  raise '!' if @trusted_sources.key?('NoSuchWord')
  raise '!' unless @trusted_sources.key?('WebJob')
}
puts Time.now - start_time





