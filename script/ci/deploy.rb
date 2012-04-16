#!/usr/bin/env ruby
#
# Continuous Deployment script
#
#   automated deployment, e.g. via post-build job (e.g. via Jenkins)
#
# Usage:
#  !/bin/bash
#  source /var/lib/jenkins/.rvm/scripts/rvm
#  source $WORKSPACE/.rvmrc
#  $WORKSPACE/script/ci/deploy.rb <APP NAME>

require File.join(File.dirname(__FILE__), '../../lib/', 'script_helper')
include ScriptHelper

WORKSPACE = ENV['WORKSPACE'] || "."
#BACKUP_DIR = "../tmp/"
BACKUP_DIR = "/home/shared/hrt_backups"
LOG_FILE = "continuous_deploy.log"
APP = ARGV[0] || 'resourcetracking'

backed_up = migrated = false

backed_up = run "#{WORKSPACE}/db/cron/db_backup.rb #{APP} #{BACKUP_DIR} >> #{BACKUP_DIR}/#{LOG_FILE}"
if backed_up
  run_or_die "heroku maintenance:on --app #{APP}"
  migrated = run "heroku rake db:migrate --app #{APP}"
  run_or_die "heroku maintenance:off --app #{APP}"
end
fail_and_exit unless backed_up and migrated
migrated
