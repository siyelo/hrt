class AddIndexForCodeIdCodeTypeInCodeSplits < ActiveRecord::Migration
  def up
    add_index :code_splits, [:code_id, :code_type]
  end

  def down
    remove_index :code_splits, [:code_id, :code_type]
  end
end
