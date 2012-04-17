require 'factory_girl'
Dir[File.expand_path(File.join(File.dirname(__FILE__),'../','../','spec','factories','**','*.rb'))].each {|f| require f}
## REPORTER
begin
  puts "creating org"
  @org = Factory(:organization, :name => "internal_reporter_org")
  puts "creating reporter user"
  @reporter = Factory(:reporter, :email => 'reporter@hrtapp.com', :organization => @org,
    :password => ENV['HRT_REPORTER_PASSWORD'] || 'si@yelo',
    :password_confirmation => ENV['HRT_REPORTER_PASSWORD'] || 'si@yelo')
rescue ActiveRecord::RecordInvalid => e
  puts e.message
  puts "   Do you already have an org 'internal_reporter_org' or user named 'reporter'? "
else
  puts "=> reporter #{@reporter.name} created (org: #{@reporter.organization.name})"
end

begin
  @reporter ||= User.find_by_email 'reporter@hrtapp.com'
  puts "creating project"
  @org = @reporter.organization
  resp = @reporter.current_response
  @project = Factory :project, :organization => @org, :data_response => resp
  puts "creating activity & coding"
  Factory(:activity_fully_coded, :project => @project, :data_response => resp)
  puts "creating other costs & coding"
  Factory(:other_cost_fully_coded, :project => @project, :data_response => resp)
  puts "=> added sample data for reporter #{@reporter.name}"
rescue Exception => e
  puts e.message
end
