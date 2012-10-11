FactoryGirl.define do
  factory :currency, class: Currency do |f|
    f.from   { 'BWP' }
    f.to     { 'ZAR' }
    f.rate   { 199 }
  end
end
