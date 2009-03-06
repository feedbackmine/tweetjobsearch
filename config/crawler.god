#run it:  god -c config/crawler.god
#check status: god status
#read log: god log crawler
#It is easy to test by not making god run as daemon:  god -c crawler.god -D

God.watch do |w|
  w.name = "crawler"
  w.interval = 30.seconds # default      

  w.start = "cd /mnt/web/current; RAILS_ENV=production jobs/crawler.rb & echo $! > /tmp/crawler.pid"
  w.stop = "kill -9 `cat /tmp/crawler.pid`"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/tmp/crawler.pid"
  
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
