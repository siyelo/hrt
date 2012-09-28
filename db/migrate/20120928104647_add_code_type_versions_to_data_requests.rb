class AddCodeTypeVersionsToDataRequests < ActiveRecord::Migration
  def up
    add_column :data_requests, :locations_version, :integer
    add_column :data_requests, :purposes_version, :integer
    add_column :data_requests, :inputs_version, :integer
    add_column :data_requests, :beneficiaries_version, :integer

    DataRequest.reset_column_information
    DataRequest.all.each do |data_request|
      data_request.locations_version = 1
      data_request.purposes_version = 1
      data_request.inputs_version = 1
      data_request.beneficiaries_version = 1
      data_request.save!
    end
  end

  def down
    remove_column :data_requests, :locations_version
    remove_column :data_requests, :purposes_version
    remove_column :data_requests, :inputs_version
    remove_column :data_requests, :beneficiaries_version
  end
end
