class RemoveFundingFlowsWithoutAProject < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20120424_remove_funding_flows_without_a_project.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
