class AddLocationToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :location_id, :integer
    drop_table :locations_organizations
  end

  def self.down
    create_table :locations_organizations, :id => false do |t|
      t.references :location
      t.references :organization
    end
    remove_column :organizations, :location_id, :integer
  end
end
