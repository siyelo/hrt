# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Hrt
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{Rails.root}/app/models/**/"]
    config.encoding = 'utf-8'
    config.time_zone = 'UTC'

    # Observers
    config.active_record.observers = :comment_observer

    # disable spoofing check
    # http://pivotallabs.com/users/jay/blog/articles/1216-standup-4-7-2010-disabling-rails-ip-spoofing-safeguard
    # PT: https://www.pivotaltracker.com/story/show/6509545
    # config.action_controller.ip_spoofing_check = false
    config.action_dispatch.ip_spoofing_check = false

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.template_engine :haml
    end

    # don't access the DB or load models when precompiling assets.
    config.assets.initialize_on_precompile = false

    # config.assets.precompile << /(^[^_]|\/[^_])[^\/]*/
    # config.assets.precompile += ['polyfills.js']
  end
end
