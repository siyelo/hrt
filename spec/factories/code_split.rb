FactoryGirl.define do
  factory :code_split, :class => CodeSplit do |f|
    f.code                 { FactoryGirl.create :purpose }
    f.cached_amount        { 1000 }
    f.percentage           { 100 }
    f.sum_of_children      { 0 } # db default value - used in specs
  end

  factory :location_budget_split, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :location }
    f.is_spend        { false }
  end

  factory :location_spend_split, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :location }
    f.is_spend        { true }
  end

  factory :input_budget_split, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :input }
    f.is_spend        { false }
  end

  factory :input_spend_split, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :input }
    f.is_spend        { true }
  end

  factory :purpose_budget_split, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :purpose }
    f.is_spend        { false }
  end

  factory :purpose_spend_split, :parent => :code_split do |f|
    f.code            { FactoryGirl.create :purpose }
    f.is_spend        { true }
  end
end
