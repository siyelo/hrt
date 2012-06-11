# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Hrt::Application.initialize!


require 'array_extensions'
require 'version'

# SQLite does not have a TO_CHAR() method
# adding this workaround to support using sqlite (e.g. test environments)
adapter_name = ActiveRecord::Base.connection.adapter_name
if adapter_name == "SQLite"
  #unfortunately sqlite doesnt support month names
  CURRENT_LOGIN_TO_CHAR = 'STRFTIME(\'%d %m %Y\', current_login_at)'
else
  CURRENT_LOGIN_TO_CHAR = 'TO_CHAR(current_login_at, \'DD Mon YYYY\')'
end
