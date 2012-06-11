# the exact error is `uninitialized constant Delayed::Job`
# in your config/initializers/delayed_job.rb

# disable delayed job for test and cucumber environment
if Rails.env == 'test'
  module Delayed::MessageSending::ClassMethods
    def handle_asynchronously(method, opts = {})
    end
  end
end
