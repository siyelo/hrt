require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UsersController do
  describe 'admin protected endpoints' do
    let(:organization) { Factory :organization, :name => "Siyelo" }
    let(:user1) { Factory :user, :full_name => 'Frank', :organization => organization }

    it "should search by user name" do
      login user1 #need to reference it so it gets built
      login Factory(:admin)
      get :index, :query => 'rank', :direction => 'asc'
      response.should render_template('admin/users/index')
      assigns(:users).should == [user1]
    end

    it "should search by org name" do
      login user1
      login Factory(:admin)
      get :index, :query => 'iyelo', :direction => 'asc'
      response.should render_template('admin/users/index')
      assigns(:users).should == [user1]
    end
  end
end
