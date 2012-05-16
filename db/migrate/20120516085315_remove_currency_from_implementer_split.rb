class RemoveCurrencyFromImplementerSplit < ActiveRecord::Migration
  def self.up
    remove_column :implementer_splits, :currency
  end

  def self.down
    add_column :implementer_splits, :currency, :string
  end
end
