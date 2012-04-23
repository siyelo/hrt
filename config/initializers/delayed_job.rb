# the exact error is `uninitialized constant Delayed::Job`
# in your config/initializers/delayed_job.rb

Delayed::Worker.backend = :active_record
require 'importer'
#require 'implementer_split'



# disable delayed job for test and cucumber environment
if RAILS_ENV == 'test' || RAILS_ENV == 'cucumber'
  module Delayed::MessageSending::ClassMethods
    def handle_asynchronously(method, opts = {})
    end
  end
end
