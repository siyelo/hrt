class RenameCostCategoryToInput < ActiveRecord::Migration
  def up
    Code.update_all({:type => "Input"}, {:type => "CostCategory"})
  end

  def down
    Code.update_all({:type => "CostCategory"}, {:type => "Input"})
  end
end
