class RemoveTypeFromCodeSplit < ActiveRecord::Migration
  def up
    remove_column :code_splits, :type
  end

  def down
    add_column :code_splits, :type, :string
  end
end
