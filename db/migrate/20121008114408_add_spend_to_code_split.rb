class AddSpendToCodeSplit < ActiveRecord::Migration
  def change
    add_column :code_splits, :spend, :boolean, default: false
  end
end
