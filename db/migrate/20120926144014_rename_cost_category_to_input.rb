class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  acts_as_nested_set
end

class RenameCostCategoryToInput < ActiveRecord::Migration
  def up
    Code.update_all({:type => "Input"}, {:type => "CostCategory"})
  end

  def down
    Code.update_all({:type => "CostCategory"}, {:type => "Input"})
  end
end
