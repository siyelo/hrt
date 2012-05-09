class UnapproveActivitiesOnRejectedResponses < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110509_unapprove_activities_on_rejected_responses.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
