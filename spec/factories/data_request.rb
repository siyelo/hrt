FactoryGirl.define do
  factory :request, class: DataRequest do |f|
    f.sequence(:title)  { |i| "data_request_title_#{i}" }
    f.organization      { FactoryGirl.create(:organization) }
    f.start_date        { "2010-01-01" }
  end

  # deprecated
  factory :data_request, class: DataRequest, parent: :request do |f|
  end
end
