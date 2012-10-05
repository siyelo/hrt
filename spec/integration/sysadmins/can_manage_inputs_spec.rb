require 'spec_helper'

describe "Sysadmins" do

  before :each do
    login_as_sysadmin
  end

  it "can edit locations" do
    FactoryGirl.create(:input, name: 'Infrastructure')

    click_link "Codes"
    click_link "Inputs"
    click_link "Infrastructure"
    fill_in "Name", with: "Women of reproductive age (15-44 years)"
    click_button "Update Input"
    page.should have_content("Input was successfully updated")
  end

  it "can search locations" do
    FactoryGirl.create(:input, name: 'Infrastructure',
                       description: 'Infrastructure railways, roads, ...')
    FactoryGirl.create(:input, name: 'Medical equipment')

    click_link "Codes"
    click_link "Inputs"

    page.should have_content('Infrastructure')
    page.should have_content('Medical equipment')

    fill_in "query", with: "medical"
    click_button("Search")

    page.should_not have_content('Infrastructure')
    page.should have_content('Medical equipment')

    fill_in "query", with: "railway"
    click_button("Search")

    page.should have_content('Infrastructure')
    page.should_not have_content('Medical equipment')
  end
end
