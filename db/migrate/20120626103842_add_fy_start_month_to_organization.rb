class AddFyStartMonthToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :fy_start_month, :integer
  end
end
