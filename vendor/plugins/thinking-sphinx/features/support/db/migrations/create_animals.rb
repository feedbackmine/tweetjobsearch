ActiveRecord::Base.connection.create_table :animals, :force => true do |t|
  t.column :name,   :string,  :null => false
  t.column :type,   :string
  t.column :delta,  :boolean, :null => false, :default => false
end

%w( rogue nat molly jasper moggy ).each do |name|
  Cat.create :name => name
end
