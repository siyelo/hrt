class AddDataRequestIdToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :data_request_id, :integer
  end

  def self.down
    remove_column :reports, :data_request_id
  end
end
