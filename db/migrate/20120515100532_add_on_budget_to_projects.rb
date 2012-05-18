class AddOnBudgetToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :budget_type, :string
  end

  def self.down
    remove_column :projects, :budget_type
  end
end
