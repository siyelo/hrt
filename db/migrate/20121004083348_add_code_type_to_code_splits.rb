class AddCodeTypeToCodeSplits < ActiveRecord::Migration
  def change
    add_column :code_splits, :code_type, :string
  end
end
