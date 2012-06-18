class RemoveApprovedAndAmApprovedFromActivities < ActiveRecord::Migration
  def up
    remove_column :activities, :approved
    remove_column :activities, :am_approved
    remove_column :activities, :am_approved_date
  end

  def down
    add_column :activities, :approved, :boolean
    add_column :activities, :am_approved, :boolean
    add_column :activities, :am_approved_date, :date
  end
end
