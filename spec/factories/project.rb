FactoryGirl.define do
  factory :project, class: Project do |f|
    f.sequence(:name)     { |i| "project_name_#{i}" }
    f.description         { 'project_description' }
    f.budget_type         { "on" }
    f.start_date          { "2010-01-01" }
    f.end_date            { "2010-12-31" }
    f.currency            { "USD" }
    f.in_flows            { |funder|
      [ funder.association(:in_flow,
                           from: funder.data_response.organization)]}
  end
end
