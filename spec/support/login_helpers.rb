def login( user = FactoryGirl.build(:reporter) )
  sign_in user
end


# deprecate
def login_as_admin
  # mock current_response_is_latest? method for Users
  # CAUTION: current_response_is_latest? method of model
  # will probably be redefined for all future specs !?
  #User.class_eval{ def current_response_is_latest?; true; end }
  # does not work in this version of RSpec
  # User.any_instance.stubs(:current_response_is_latest?).returns(true)
  @data_request = FactoryGirl.create :data_request
  @admin_org = FactoryGirl.create :organization
  @admin = FactoryGirl.create(:admin, organization: @admin_org)
  sign_in @admin
end

def login_as_sysadmin
  organization = FactoryGirl.create(:organization, name: 'organization1')
  sysadmin = FactoryGirl.create(:admin, email: 'admin@hrtapp.com',
                                organization: organization)
  visit root_path
  fill_in "Email", with: sysadmin.email
  fill_in "Password", with: 'password'
  click_button "Sign in"
end
