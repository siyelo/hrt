class AddCodeTypeToCodeSplits < ActiveRecord::Migration
  def change
    add_column :code_splits, :code_type, :string
    CodeSplit.reset_column_information
  end
end
