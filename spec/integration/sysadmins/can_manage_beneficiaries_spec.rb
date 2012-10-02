require 'spec_helper'

describe "Sysadmins" do

  before :each do
    login_as_sysadmin
  end

  it "can edit beneficiaries" do
    beneficiary = FactoryGirl.create(:beneficiary, name: 'Sex workers')

    click_link "Codes"
    click_link "Beneficiaries"
    click_link "Sex workers"
    fill_in "Name", with: "Women of reproductive age (15-44 years)"
    click_button "Update Beneficiary"
    page.should have_content("Beneficiary was successfully updated")
  end

  it "can search beneficiaries"
end
