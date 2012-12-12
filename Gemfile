source 'http://rubygems.org'

gem 'rails', '3.2.6'
gem 'jquery-rails'
gem 'jquery-ui-themes'
gem 'pg'
gem 'haml'
gem 'settingslogic'
gem 'inherited_resources'
gem 'acts_as_tree'
gem 'ar_strip_commas'
gem 'devise'
gem 'devise-encryptable'
gem 'awesome_nested_set'
gem 'aws-sdk', '~> 1.3.4'
gem 'delayed_job_active_record'
gem 'formtastic'
gem 'json_pure'
gem 'money', '~> 3.5'
gem 'paperclip'
gem 'rack-timeout'
gem 'spreadsheet'
gem 'SystemTimer', :require => 'system_timer', :platforms => :ruby_18
gem 'validates_timeliness'
gem 'version'
gem 'will_paginate'
gem 'addressable'
gem 'axlsx'
gem 'rubyzip'
gem 'newrelic_rpm'
gem 'airbrake', '3.1.2'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails'
  gem 'compass-h5bp'
end

group :development do
  gem 'annotate'
  gem 'heroku'
  gem 'rails-footnotes'
  gem 'taps'
  gem 'quiet_assets'
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'growl',      :require => RUBY_PLATFORM.include?('darwin') && 'growl'
  gem 'rb-inotify', :require => RUBY_PLATFORM.include?('linux')  && 'rb-inotify'
  gem 'libnotify',  :require => RUBY_PLATFORM.include?('linux')  && 'rb-inotify'
end

group :test, :development do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'sqlite3'
end

group :test do
  gem 'poltergeist'
  gem 'database_cleaner'
  gem "factory_girl_rails", "~> 3.0"
  gem 'guard-spork'
  gem 'capybara'
  gem 'launchy', "= 2.1.0"
  gem 'email_spec'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'pickle'
  gem 'cucumber-rails', '~> 1.0', :require => false
  gem 'cucumber-rails-training-wheels'
end
