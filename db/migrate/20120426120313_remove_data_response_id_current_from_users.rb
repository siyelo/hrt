class RemoveDataResponseIdCurrentFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :data_response_id_current
  end

  def self.down
    add_column :users, :data_response_id_current, :integer
  end
end
