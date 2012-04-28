class RemoveCodingValidsFromActivity < ActiveRecord::Migration
  def self.up
    remove_column :activities, :coding_budget_valid
    remove_column :activities, :coding_budget_cc_valid
    remove_column :activities, :coding_budget_district_valid
    remove_column :activities, :coding_spend_valid
    remove_column :activities, :coding_spend_cc_valid
    remove_column :activities, :coding_spend_district_valid
  end

  def self.down
    add_column :activities, :coding_budget_valid, :boolean, :default => false
    add_column :activities, :coding_budget_district_valid, :boolean, :default => false
    add_column :activities, :coding_budget_cc_valid, :boolean, :default => false
    add_column :activities, :coding_spend_valid, :boolean, :default => false
    add_column :activities, :coding_spend_cc_valid, :boolean, :default => false
    add_column :activities, :coding_spend_district_valid, :boolean, :default => false
  end
end
