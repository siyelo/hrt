FactoryGirl.define do
  factory :code, :class => Code do |f|
    f.sequence(:short_display)   { |i| "code_#{i}" }
    f.sequence(:description)     { |i| "description_#{i}" }
    f.sequence(:long_display)    { |i| "long_display_#{i}" }
  end

  factory :purpose, :class => Purpose, :parent => :code do |f|
  end

  factory :input, :class => Input, :parent => :code do |f|
  end

  # todo - deprecate
  factory :cost_category_code, :parent => :input do |f|
  end

  factory :location, :class => Location, :parent => :code do |f|
  end

  factory :beneficiary, :class => Beneficiary, :parent => :code do |f|
  end

  factory :hssp_strat_prog, :class => HsspStratProg, :parent => :code do |f|
  end

  factory :hssp_strat_obj, :class => HsspStratObj, :parent => :code do |f|
  end
end
