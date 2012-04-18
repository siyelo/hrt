require File.dirname(__FILE__) + '/../spec_helper'

describe StaticPageController do
  describe "#index" do
    let(:document) { stub(:document) }

    it "redirect to dashboard if user is logged in" do
      login(Factory(:reporter))

      get :index
      response.should redirect_to(dashboard_path)
    end

    it "loads public documents if user is not logged in" do
      Document.stub_chain(:visible_to_public, :latest_first).and_return([document])

      get :index
      assigns(:documents).should == [document]
      response.should render_template('index')
    end

    it "does not render layout when ajax request" do
      Document.stub_chain(:visible_to_public, :latest_first).and_return([document])

      xhr :get, :index
      assigns(:documents).should == [document]
      response.should render_template('static_page/_documents')
    end
  end
end
