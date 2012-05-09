require 'spec_helper'

describe DashboardController do
  context "visitor" do
    describe "it should be protected" do
      before :each do get :index end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access this page") }
    end
  end

  ['reporter', 'activity_manager', 'sysadmin'].each do |role|
    context role do
      describe "#index" do
        it "renders doshboard" do
          organization = Factory(:organization)
          Factory(:data_request, :organization => organization)
          user = Factory(role, :organization => organization)
          login(user)

          dashboard = stub('dashboard', :template => role)
          Dashboard.stub(:new).and_return(dashboard)

          get :index
          response.should be_success
          response.should render_template(role)
        end
      end
    end
  end

  describe "no request" do
    it "renders no_request template when no request" do
      sysadmin = Factory(:sysadmin)
      login sysadmin
      get :index
      response.should be_success
      response.should render_template('no_request')
    end
  end
end
