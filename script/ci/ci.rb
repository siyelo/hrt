#!/usr/bin/env ruby

# CI server test script
#   Runs all specs and cukes

# Usage:
#  !/bin/bash
#  source /var/lib/jenkins/.rvm/scripts/rvm
#  source $WORKSPACE/.rvmrc
#  $WORKSPACE/script/ci/ci.rb
#

require File.join(File.dirname(__FILE__), '../../lib/', 'script_helper')
include ScriptHelper

WORKSPACE=ENV['WORKSPACE'] || "../"

def bundle_install
  #result = run "bundle check"
  #run_or_die "bundle install" unless result == true
  run_or_die "bundle install"
end

def setup_db_config
  #run_or_die "cp #{WORKSPACE}/config/database.yml.sample.sqlite3 #{WORKSPACE}/config/database.yml"
  run "cp #{WORKSPACE}/config/database.yml.sample.pg #{WORKSPACE}/config/database.yml"
end

def setup_specs
  ENV['RAILS_ENV'] = 'test'
  run_or_die "rake setup_quick --trace RAILS_ENV=test"
end

def specs
  setup_specs
  run_or_die "bundle exec rspec spec"
  #run_or_die "spec spec/models/<pick_some_quick_spec>.rb" #debug
end

# http://blog.kabisa.nl/2010/05/24/headless-cucumbers-and-capybaras-with-selenium-and-hudson/
# and http://markgandolfo.com/2010/07/01/hudson-ci-server-running-cucumber-in-headless-mode-xvfb
def setup_cukes
  ENV['RAILS_ENV'] = 'cucumber'
  ENV['DISPLAY'] = ":0.0"
end

def cukes
  setup_cukes
  run_or_die "bundle exec cucumber features"
end

# main
bundle_install
setup_db_config
specs
cukes
run_or_die "rake clean"
