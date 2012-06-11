require 'spec_helper'

describe DocumentsController do
  describe "#index" do
    let(:user) { FactoryGirl.create(:reporter) }

    it "required logged in user" do
      get :index
      response.should redirect_to(root_url)
    end

    it "displays only reporter visible documents" do
      login(user)
      controller.stub(:current_user).and_return(user)
      user.stub_chain(:data_responses, :find)
      Document.stub_chain(:visible_to_reporters, :paginate).and_return([])
      Document.should_receive(:visible_to_reporters)

      get :index
      response.should be_success
    end
  end
end
