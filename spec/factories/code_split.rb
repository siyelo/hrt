Factory.define :code_split, :class => CodeSplit do |f|
  f.code                 { Factory.create :code }
  f.cached_amount        { 1000 }
  f.percentage           { 100 }
  f.sum_of_children      { 0 } # db default value - used in specs
end

Factory.define :purpose_budget_split, :class => PurposeBudgetSplit, :parent => :code_split do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :location_budget_split, :class => LocationBudgetSplit, :parent => :code_split do |f|
  f.code            { Factory.create :location }
end

Factory.define :input_budget_split, :class => InputBudgetSplit, :parent => :code_split do |f|
  f.code            { Factory.create :input}
end

Factory.define :purpose_spend_split, :class => PurposeSpendSplit, :parent => :code_split do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :location_spend_split, :class => LocationSpendSplit, :parent => :code_split do |f|
  f.code            { Factory.create :location }
end

Factory.define :input_spend_split, :class => InputSpendSplit, :parent => :code_split do |f|
  f.code            { Factory.create :input }
end

Factory.define :budget_purpose, :class => PurposeBudgetSplit, :parent => :code_split do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :budget_location, :class => LocationBudgetSplit, :parent => :code_split do |f|
  f.code            { Factory.create :location }
end

Factory.define :budget_input, :class => InputBudgetSplit, :parent => :code_split do |f|
  f.code            { Factory.create :cost_category_code }
end

Factory.define :spend_purpose, :class => PurposeSpendSplit, :parent => :code_split do |f|
  f.code            { Factory.create :mtef_code }
end

Factory.define :spend_location, :class => LocationSpendSplit, :parent => :code_split do |f|
  f.code            { Factory.create :location }
end

Factory.define :spend_input, :class => InputSpendSplit, :parent => :code_split do |f|
  f.code            { Factory.create :cost_category_code }
end

