FactoryGirl.define do
  factory :code_split, :class => CodeSplit do |f|
    f.code                 { FactoryGirl.create :code }
    f.cached_amount        { 1000 }
    f.percentage           { 100 }
    f.sum_of_children      { 0 } # db default value - used in specs
  end

  factory :purpose_budget_split, :class => PurposeBudgetSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :purpose }
  end

  factory :location_budget_split, :class => LocationBudgetSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :location }
  end

  factory :input_budget_split, :class => InputBudgetSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :input}
  end

  factory :purpose_spend_split, :class => PurposeSpendSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :purpose }
  end

  factory :location_spend_split, :class => LocationSpendSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :location }
  end

  factory :input_spend_split, :class => InputSpendSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :input }
  end

  factory :budget_purpose, :class => PurposeBudgetSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :purpose }
  end

  factory :budget_location, :class => LocationBudgetSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :location }
  end

  factory :budget_input, :class => InputBudgetSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :input }
  end

  factory :spend_purpose, :class => PurposeSpendSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :purpose }
  end

  factory :spend_location, :class => LocationSpendSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :location }
  end

  factory :spend_input, :class => InputSpendSplit, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :input }
  end
end
