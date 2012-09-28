require 'spec_helper'

describe Admin::CodesController do

  describe "#index" do
    before :each do
      login_as_admin
    end

    it "shows latest version only" do
      version1 = FactoryGirl.create(:input, version: 1)
      version2 = FactoryGirl.create(:input, version: 2)

      get :index, filter: 'Inputs'

      codes = assigns(:codes)
      codes.should include(version2)
      codes.should_not include(version1)
    end
  end
end
