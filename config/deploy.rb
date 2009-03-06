set :application, "tweetjobsearch"
set :repository, "git://github.com/feedbackmine/tweetjobsearch.git"
set :user, 'root'
#set :password, 'password'
set :use_sudo, false
set :ssh_options, { :paranoid => true, :forward_agent => true}
set :deploy_to, "/mnt/web"
set :scm, :git

role :app, 'www.tweetjobsearch.com'
role :web, 'www.tweetjobsearch.com'
role :db,  'www.tweetjobsearch.com', :primary => true

namespace :deploy do
  desc "Restarting mod_rails/crawler/sphinx"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
    run "touch /tmp/restart-crawler.txt"
    restart_sphinx
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

desc "Re-establish symlinks"
task :after_symlink, :roles => :app do
  run <<-CMD
    rm -rf #{release_path}/db/sphinx &&
    ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
  CMD
end

task :after_update_code, :roles => :app do
  run "cp #{release_path}/config/database.yml.template #{release_path}/config/database.yml"
  run "touch #{release_path}/log/production.log"
  run "chmod 0666 #{release_path}/log/production.log"
  run "chmod a+w #{release_path}/tmp"
  run "chmod a+w #{release_path}/public/javascripts"
  run "chmod a+w #{release_path}/public/stylesheets"
end

desc "Stop the sphinx server"
task :stop_sphinx , :roles => :app do
  run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:stop RAILS_ENV=production"
end

desc "Start the sphinx server"
task :start_sphinx, :roles => :app do
  run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:start RAILS_ENV=production"
end

desc "Restart the sphinx server"
task :restart_sphinx, :roles => :app do
  stop_sphinx
  start_sphinx
end  

desc "backup training data"
task :backup, :roles => :app do
  run "mysqldump -u root tweetjobsearch training_tweets | gzip -c > training_tweets.sql.gz"
  `scp root@tweetjobsearch.com:~/training_tweets.sql.gz training_tweets.sql.gz`
end  

