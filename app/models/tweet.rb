class Tweet < ActiveRecord::Base
  define_index do
    indexes text
    has created_at
    set_property :delta => true
  end
  
  #"SELECT count(*) AS count_all FROM `tweets`;" is very slow with InnoDB engine.
  #http://revolutiononrails.blogspot.com/2007/05/acts-as-fast-but-very-inaccurate.html
  #http://groups.google.com/group/will_paginate/browse_thread/thread/4200032b25732f77
  def self.count(*args)
    #this result is approximated, but not way off based on my experience
    ActiveRecord::Base.connection.select_one("SHOW TABLE STATUS LIKE '#{table_name}'")['Rows'].to_i
  end
end

