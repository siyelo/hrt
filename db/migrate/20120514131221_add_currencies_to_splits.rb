class AddCurrenciesToSplits < ActiveRecord::Migration
  def self.up
    add_column :implementer_splits, :currency, :string
  end

  def self.down
    remove_column :implementer_splits, :currency
  end
end
