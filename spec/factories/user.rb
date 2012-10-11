#:user is kind of lame without any roles

FactoryGirl.define do
  factory :user, class: User do |f|
    f.sequence(:full_name)  { "Some User" }
    f.sequence(:email)      { |i| "user_email_#{i}@example.com" }
    f.password              { 'password' }
    f.password_confirmation { 'password' }
    f.organization          { FactoryGirl.create(:organization) }
    f.active                { true }
    f.roles                 { ['reporter'] }
  end

  factory :reporter,  parent: :user do |f|
    f.sequence(:full_name)  { "Some Reporter" }
    f.sequence(:email)      { |i| "reporter_email_#{i}@example.com" }
    f.roles                 { ['reporter'] }
  end

  factory :activity_manager,  parent: :user do |f|
    f.sequence(:full_name)  { "Some Activity Manager" }
    f.sequence(:email)      { |i| "activity_manager_#{i}@example.com" }
    f.roles                 { ['activity_manager'] }
  end

  factory :sysadmin,  parent: :user do |f|
    f.sequence(:full_name)  { "Some Sysadmin" }
    f.sequence(:email)      { |i| "sysadmin_#{i}@example.com" }
    f.roles                 { ['admin'] }
  end

  # deprecated - use :sysadmin from now on
  factory :admin,  parent: :sysadmin do |f|
  end
end
