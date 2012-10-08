class LocationSplit < CodeSplit; end
class LocationBudgetSplit < LocationSplit; end
class LocationSpendSplit < LocationSplit; end

class InputSplit < CodeSplit; end
class InputBudgetSplit < InputSplit; end
class InputSpendSplit < InputSplit; end

class PurposeSplit < CodeSplit; end
class PurposeBudgetSplit < PurposeSplit; end
class PurposeSpendSplit < PurposeSplit; end

CodeSplit.reset_column_information
LocationSplit.reset_column_information
LocationBudgetSplit.reset_column_information
LocationSpendSplit.reset_column_information
InputSplit.reset_column_information
InputBudgetSplit.reset_column_information
InputSpendSplit.reset_column_information
PurposeSplit.reset_column_information
PurposeBudgetSplit.reset_column_information
PurposeSpendSplit.reset_column_information

CodeSplit.find_each do |code_split|
  if code_split.type.to_s =~ /Spend/
    code_split.is_spend = true
    code_split.save!
  end
end
