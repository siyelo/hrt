require 'spec_helper'

describe DocumentsController do
  describe "user permissions" do
    it_should_require_reporter_for :index
  end

  describe "#index" do
    before :each do
      login(Factory(:reporter))
    end

    it "displays only reporter visible documents" do
      Document.should_receive(:visible_to_reporters).and_return([])

      get :index
      response.should be_success
    end
  end
end
