require 'spec_helper'

describe "Reporter" do

  let(:organization) { FactoryGirl.create(:organization,
                                      name: 'test organization') }
  let(:reporter) { FactoryGirl.create(:reporter, organization: organization) }

  it "can navigate previous response" do
    FactoryGirl.create(:data_request, organization: organization,
                       name: "Request 1", start_date: "2010-01-01")
    FactoryGirl.create(:data_request, organization: organization,
                       name: "Request 2", start_date: "2011-01-01")

    login_as(reporter)

    click_link "Projects & Activities"
    page.should have_content("Request 2")
    page.should_not have_content("Request 1")

    click_link "Previous Request"
    page.should_not have_content("Request 2")
    page.should have_content("Request 1")

    click_link "Next Request"
    page.should_not have_content("Request 1")
    page.should have_content("Request 2")
  end
end
