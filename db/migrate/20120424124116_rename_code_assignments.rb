class RenameCodeAssignments < ActiveRecord::Migration
  def self.up
    rename_table :code_assignments, :code_splits

    ActiveRecord::Base.connection.execute "UPDATE code_splits SET type='InputBudgetSplit' WHERE type='CodingBudgetCostCategorization'"
    ActiveRecord::Base.connection.execute "UPDATE code_splits SET type='InputSpendSplit' WHERE type='CodingSpendCostCategorization'"
    ActiveRecord::Base.connection.execute "UPDATE code_splits SET type='LocationBudgetSplit' WHERE type='CodingBudgetDistrict'"
    ActiveRecord::Base.connection.execute "UPDATE code_splits SET type='LocationSpendSplit' WHERE type='CodingSpendDistrict'"
    ActiveRecord::Base.connection.execute "UPDATE code_splits SET type='PurposeBudgetSplit' WHERE type='CodingBudget'"
    ActiveRecord::Base.connection.execute "UPDATE code_splits SET type='PurposeSpendSplit' WHERE type='CodingSpend'"
  end

  def self.down
    rename_table :code_splits, :code_assignments

    ActiveRecord::Base.connection.execute "UPDATE code_assignments SET type='CodingBudgetCostCategorization' WHERE type='InputBudgetSplit'"
    ActiveRecord::Base.connection.execute "UPDATE code_assignments SET type='CodingSpendCostCategorization' WHERE type='InputSpendSplit'"
    ActiveRecord::Base.connection.execute "UPDATE code_assignments SET type='CodingBudgetDistrict' WHERE type='LocationBudgetSplit'"
    ActiveRecord::Base.connection.execute "UPDATE code_assignments SET type='CodingSpendDistrict' WHERE type='LocationSpendSplit'"
    ActiveRecord::Base.connection.execute "UPDATE code_assignments SET type='CodingBudget' WHERE type='PurposeBudgetSplit'"
    ActiveRecord::Base.connection.execute "UPDATE code_assignments SET type='CodingSpend' WHERE type='PurposeSpendSplit'"
  end
end
