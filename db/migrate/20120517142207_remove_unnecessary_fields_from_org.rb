class RemoveUnnecessaryFieldsFromOrg < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :fiscal_year_end_date
    remove_column :organizations, :fiscal_year_start_date
  end

  def self.down
    add_column :organizations, :fiscal_year_end_date, :datetime
    add_column :organizations, :fiscal_year_start_date, :datetime
  end
end
