require 'spec_helper'

shared_examples_for 'an organization controller' do
  it "should allow admin to edit settings of reporting organization" do
    o = FactoryGirl.create :organization
    get :edit, :id => :current
    response.should be_success
  end
  it "should allow admin to edit settings of nonreporting org" do
    o = FactoryGirl.create :organization, :raw_type => 'Communal FOSA'
    get :edit, :id => :current
    response.should be_success
  end
end

describe OrganizationsController do
  context "as a reporter" do
    before :each do
      data_request  = FactoryGirl.create(:data_request)
      organization  = FactoryGirl.create(:organization)
      reporter       = FactoryGirl.create(:reporter, :organization => organization)
      login(reporter)
    end

    it "redirects to dashboard_path" do
      put :update, :id => :current
      response.should redirect_to(edit_organization_path(:current))
    end

    it "downloads csv template" do
      Organization.should_receive(:download_template).and_return('csv')
      get :export
      response.should be_success
      response.header["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
      response.header["Content-Disposition"].should == "attachment; filename=organizations.csv"
    end

    it_should_behave_like 'an organization controller'
  end

  context "as a sysadmin" do
    before :each do
      data_request  = FactoryGirl.create(:data_request)
      organization  = FactoryGirl.create(:organization)
      sysadmin      = FactoryGirl.create(:sysadmin, :organization => organization)
      login(FactoryGirl.create(:sysadmin))
    end

    it_should_behave_like 'an organization controller'
  end
end
