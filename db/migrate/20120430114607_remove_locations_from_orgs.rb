class RemoveLocationsFromOrgs < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :location_id
  end

  def self.down
    add_column :organizations, :location_id, :integer
  end
end
