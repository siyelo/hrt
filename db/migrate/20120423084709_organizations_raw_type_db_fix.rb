class OrganizationsRawTypeDbFix < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20120423_add_raw_type_to_reporting_organizations.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
