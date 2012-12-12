class ChangePercentageColumnInCodeSplits < ActiveRecord::Migration
  def up
    change_column :code_splits, :percentage, :decimal, :precision => 18, :scale => 3
  end

  def down
    change_column :code_splits, :percentage, :decimal, :precision => nil, :scale => nil
  end
end
