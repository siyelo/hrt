class AddDecomissionFieldToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :decomissioned, :boolean, default: false
  end
end
