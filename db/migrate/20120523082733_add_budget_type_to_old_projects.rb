class AddBudgetTypeToOldProjects < ActiveRecord::Migration
  def self.up
    Project.reset_column_information
    load 'db/fixes/20120523_add_budget_type_to_old_projects.rb'
  end

  def self.down
    p 'IRREVERSIBLE MIGRATION'
  end
end
