class AddIsSpendToCodeSplit < ActiveRecord::Migration
  def change
    add_column :code_splits, :is_spend, :boolean, default: false
  end
end
