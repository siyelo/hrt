require 'rubygems'
require 'spork'
require "paperclip/matchers"
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  # Shoulda
  require 'shoulda/matchers/integrations/rspec'

  # Email spec
  require 'email_spec'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false


    # Provides RSpec-compatible matchers for testing Paperclip attachments.
    config.include Paperclip::Shoulda::Matchers


    # Email spec helpers
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)

    # Devise test helpers
    config.include Devise::TestHelpers, :type => :controller

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end
    config.before :each do
      DatabaseCleaner.clean
    end
    config.after :each do
      Timecop.return
    end

    config.after(:each, type: :request) do |example|
      if ENV.include?('SHOW_ME_THE_PAGE')
        save_and_open_page if example.failed?
      end
    end

  end
end

Spork.each_run do
  # factories reload
  FactoryGirl.reload
end
