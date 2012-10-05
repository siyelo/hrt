require 'spec_helper'

describe "Sysadmins" do

  before :each do
    login_as_sysadmin
  end

  it "can edit locations" do
    FactoryGirl.create(:location, name: 'Bugesera')

    click_link "Codes"
    click_link "Locations"
    click_link "Bugesera"
    fill_in "Name", with: "Women of reproductive age (15-44 years)"
    click_button "Update Location"
    page.should have_content("Location was successfully updated")
  end

  it "can search locations" do
    FactoryGirl.create(:location, name: 'Bugesera')
    FactoryGirl.create(:location, name: 'Burera')

    click_link "Codes"
    click_link "Locations"

    page.should have_content('Bugesera')
    page.should have_content('Burera')

    fill_in "query", with: "bure"
    click_button("Search")

    page.should_not have_content('Bugesera')
    page.should have_content('Burera')
  end
end
