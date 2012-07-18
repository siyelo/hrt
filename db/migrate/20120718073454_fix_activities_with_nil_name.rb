class FixActivitiesWithNilName < ActiveRecord::Migration
  def up
    load 'db/fixes/20120718_fix_activities_with_nil_name.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
