class RemoveUselessShite < ActiveRecord::Migration
  def self.up
    remove_column :activities, :text_for_provider
    rename_column :activities, :text_for_beneficiaries, :other_beneficiaries
    remove_column :activities, :provider_id
    remove_column :activities, :ServiceLevelSpend_amount
    remove_column :activities, :ServiceLevelBudget_amount
    drop_table :activities_organizations
  end

  def self.down
    add_column :activities, :text_for_provider, :text
    rename_column :activities, :other_beneficiaries, :text_for_beneficiaries
    add_column :activities, :provider_id, :integer
    add_column :activities, :ServiceLevelSpend_amount, :decimal, :default => 0
    add_column :activities, :ServiceLevelBudget_amount, :decimal, :default => 0
    create_table :activities_organizations, :id=>false do |t|
      t.references :activity
      t.references :organization
    end
  end
end
