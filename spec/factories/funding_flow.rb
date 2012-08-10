FactoryGirl.define do
  factory :funding_flow, :class => FundingFlow do |f|
    f.from                  { FactoryGirl.create(:organization) }
  #  f.project               { FactoryGirl.create(:project) }
    f.budget                { 90 }
    f.spend                 { 100 }
    f.double_count          { false }
  end

  factory :funding_source, :class => FundingFlow, :parent => :funding_flow do |f|
  end
  factory :in_flow, :class => FundingFlow, :parent => :funding_flow do |f|
  end

  factory :implementer, :class => FundingFlow, :parent => :funding_flow do |f|
  end
end
