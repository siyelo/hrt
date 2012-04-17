class RemoveRedundantDataRequestFields < ActiveRecord::Migration
  def self.up
    remove_column :data_requests, :due_date
    remove_column :data_requests, :end_date
    remove_column :data_requests, :final_review
    remove_column :data_requests, :budget_by_quarter
  end

  def self.down
    add_column :data_requests, :due_date, :datetime
    add_column :data_requests, :end_date, :datetime
    add_column :data_requests, :final_review, :boolean, :default => false
    add_column :data_requests, :budget_by_quarter, :boolean, :default => false
  end
end
