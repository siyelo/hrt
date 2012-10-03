require 'spec_helper'

describe "Sysadmins" do

  before :each do
    login_as_sysadmin
  end

  it "can edit beneficiaries" do
    FactoryGirl.create(:beneficiary, name: 'Sex workers')

    click_link "Codes"
    click_link "Beneficiaries"
    click_link "Sex workers"
    fill_in "Name", with: "Women of reproductive age (15-44 years)"
    click_button "Update Beneficiary"
    page.should have_content("Beneficiary was successfully updated")
  end

  it "can search beneficiaries" do
    FactoryGirl.create(:beneficiary, name: 'Sex workers')
    FactoryGirl.create(:beneficiary, name: 'Young children (1-4 years)')

    click_link "Codes"
    click_link "Beneficiaries"

    page.should have_content('Sex workers')
    page.should have_content('Young children (1-4 years)')

    fill_in "query", with: "young"
    click_button("Search")

    page.should_not have_content('Sex workers')
    page.should have_content('Young children (1-4 years)')

  end
end
