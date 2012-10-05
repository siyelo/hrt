require 'spec_helper'

describe "Sysadmins" do

  before :each do
    login_as_sysadmin
  end

  it "can edit locations" do
    FactoryGirl.create(:purpose, name: 'Diseases Prevention')

    click_link "Codes"
    click_link "Purposes"
    click_link "Diseases Prevention"
    fill_in "Name", with: "Women of reproductive age (15-44 years)"
    click_button "Update Purpose"
    page.should have_content("Purpose was successfully updated")
  end

  it "can search locations" do
    FactoryGirl.create(:purpose, name: 'Diseases Prevention',
                       description: 'Diseases Prevention for HIV infected people')
    FactoryGirl.create(:purpose, name: 'Support of Higher Education for Health')

    click_link "Codes"
    click_link "Purposes"

    page.should have_content('Diseases Prevention')
    page.should have_content('Support of Higher Education for Health')

    fill_in "query", with: "support"
    click_button("Search")

    page.should_not have_content('Diseases Prevention')
    page.should have_content('Support of Higher Education for Health')

    fill_in "query", with: "hiv"
    click_button("Search")

    page.should have_content('Diseases Prevention')
    page.should_not have_content('Support of Higher Education for Health')
  end
end
