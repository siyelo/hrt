require 'Factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}

org = FactoryGirl.create(:organization)
req = FactoryGirl.create :request, :organization => org

begin
  puts "creating sysadmin"
  org = FactoryGirl.create(:organization, :name => 'System Administration')
  admin = FactoryGirl.create(:sysadmin, :email => 'sysadmin@hrtapp.com', :organization => org,
    :password => ENV['HRT_ADMIN_PASSWORD'] || 'si@yelo',
    :password_confirmation => ENV['HRT_ADMIN_PASSWORD'] || 'si@yelo')
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'System Administration' or user named 'sysadmin@hrtapp.com'? "
else
  puts "=> sysadmin user: #{admin.name} created (org: #{admin.organization.name})"
end
