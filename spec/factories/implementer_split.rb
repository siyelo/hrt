FactoryGirl.define do
  factory :implementer_split do |f|
    f.organization    { FactoryGirl.build(:organization) }
    f.spend           { 1.23 }
    f.budget          { 1.23 }
  end
end
