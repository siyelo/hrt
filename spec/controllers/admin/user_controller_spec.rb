require 'spec_helper'

describe Admin::UsersController do
  describe 'admin protected endpoints' do
    let(:organization) { FactoryGirl.create :organization, name: "Siyelo" }
    let(:user1) { FactoryGirl.create :user, full_name: 'Frank', organization: organization }

    it "should search by user name" do
      login user1 #need to reference it so it gets built
      login FactoryGirl.create(:admin)
      get :index, query: 'rank', direction: 'asc'
      response.should render_template('admin/users/index')
      assigns(:users).should == [user1]
    end

    it "should search by org name" do
      login user1
      login FactoryGirl.create(:admin)
      get :index, query: 'iyelo', direction: 'asc'
      response.should render_template('admin/users/index')
      assigns(:users).should == [user1]
    end
  end
end
