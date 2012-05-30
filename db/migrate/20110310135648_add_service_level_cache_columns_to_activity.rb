class AddServiceLevelCacheColumnsToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, "ServiceLevelBudget_amount", :decimal, :default => 0
    add_column :activities, "ServiceLevelSpend_amount", :decimal, :default => 0
  end

  def self.down
    remove_column :activities, "ServiceLevelBudget_amount"
    remove_column :activities, "ServiceLevelSpend_amount"
  end
end
