FactoryGirl.define do
  factory :document do |f|
    f.sequence(:title)   { |i| "document_#{i}" }
    f.document { File.open(File.join(Rails.root, 'spec', 'fixtures', 'activities.csv')) }
    f.visibility "public"
  end
end
