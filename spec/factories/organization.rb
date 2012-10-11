FactoryGirl.define do
  factory :organization, class: Organization do |f|
    f.sequence(:name)                  { |i| "organization_name_#{i}" }
    f.raw_type                         { "Local NGO" }
    f.currency                         { "USD" }
    f.contact_name                     { "Bob" }
    f.contact_position                 { "Manager" }
    f.contact_phone_number             { "123123123" }
    f.contact_main_office_phone_number { "234234234" }
    f.contact_office_location          { "Cape Town" }
    f.fy_start_month                   { 1 }
  end

  factory :nonreporting_organization, class: Organization, parent: :organization do |f|
    f.users { nil }
  end
end
