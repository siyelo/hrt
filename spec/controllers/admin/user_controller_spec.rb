require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UsersController do
  describe "Routing shortcuts should map" do
    it "GET (index) with admin/users" do
      params_from(:get, '/admin/users').should == { :controller => "admin/users",
        :action => "index"}
    end
    it "POST (create) with admin/users/new" do
      params_from(:post, '/admin/users/').should == {:controller => "admin/users",
        :action => "create"}
    end
    it "GET (edit) with admin/users/1/edit" do
      params_from(:get, '/admin/users/1/edit').should == {:controller => "admin/users",
        :id => "1", :action => "edit"}
    end
    it "DELETE with /admin/users/1" do
      params_from(:delete, "/admin/users/1").should == {:controller => "admin/users",
        :id => "1", :action => "destroy"}
    end
  end

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
