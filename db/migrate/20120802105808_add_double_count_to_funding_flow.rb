class AddDoubleCountToFundingFlow < ActiveRecord::Migration
  def change
    add_column :funding_flows, :double_count, :boolean
  end
end
