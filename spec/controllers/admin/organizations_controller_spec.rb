require 'spec_helper'

describe Admin::OrganizationsController do
  before :each do
    login_as_admin
  end

  describe "#index" do
    before :each do
      # login as admin creates 1 NR and 1 Reporting org
      request1 = FactoryGirl.create(:data_request) # +1 NR
      organization = FactoryGirl.create(:organization)
      FactoryGirl.create :user, :organization => organization #+1 R
      FactoryGirl.create :organization # +1 NR
    end

    it "displays reporting organization by default" do
      get :index
      assigns(:organizations).size.should == 2
    end

    it "ignores bad filters " do
      get :index, :filter => 'blargh'
      assigns(:organizations).size.should == 2
    end

    it "filters by non-reporting" do
      get :index, :filter => "Non-Reporting"
      assigns(:organizations).size.should == 3
    end

    it "filters by all" do
      get :index, :filter => "All"
      assigns(:organizations).size.should == 5
    end
  end

  it "#show(s)" do
    organization = FactoryGirl.create(:organization)
    organization2 = FactoryGirl.create(:organization)
    get :show, :id => organization.id, :duplicate_id => organization2.id
    assigns(:target).should == organization
    assigns(:duplicate).should == organization2
  end

  describe "#destroy" do
    context "when organization has data, but no external references" do
      before :each do
        basic_setup_implementer_split_for_controller
        @organization.stub!(:destroy).and_return(true)
        Organization.stub(:find).and_return @organization
      end

      it "sets flash notice" do
        delete :destroy, :id => @organization.id
        flash[:notice].should == "Organization was successfully destroyed."
      end

      it "redirects to the duplicate_admin_organizations_path" do
        request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/organizations/duplicate'
        delete :destroy, :id => @organization.id
        response.should redirect_to(duplicate_admin_organizations_path)
      end

      it "returns proper json" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.body.should == '{"message":"Organization was successfully destroyed."}'
      end

      it "does not js redirect" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.should_not be_redirect
      end
    end


    context "when organization has references" do
      before :each do
        basic_setup_implementer_split_for_controller # will have a data_request
        @organization.stub!(:destroy).and_return(false)
        Organization.stub(:find).and_return @organization
      end

      it "sets flash notice" do
        delete :destroy, :id => @organization.id
        flash[:error].should == "You cannot delete an organization that has (external) data referencing it."
      end

      it "redirects to the duplicate_admin_organizations_path" do
        request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/organizations/duplicate'
        delete :destroy, :id => @organization.id
        response.should redirect_to(duplicate_admin_organizations_path)
      end

      it "returns proper json when request is with js format" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.body.should == '{"message":"You cannot delete an organization that has (external) data referencing it."}'
      end

      it "does not redirect with js" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.should_not be_redirect
      end

      it "sets status to :partial_content with js" do
        delete :destroy, :id => @organization.id, :format => "js"
        response.status.should == 206
      end
    end
  end

  describe "#duplicate" do
    before :each do
      @organization = FactoryGirl.create(:organization)
      organizations = [@organization]
      Organization.stub_chain(:ordered).and_return(organizations)
      Organization.stub!(:ordered).and_return(organizations)
    end

    it "assigns variables" do
      Organization.should_receive(:ordered)
      get :duplicate
      assigns(:all_organizations).should_not be_nil
    end

    it "renders duplicate template" do
      get :duplicate
      response.should render_template('admin/organizations/duplicate')
    end
  end

  describe "#remove_duplicate" do
    context "when ids are blank" do
      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:error].should == "Duplicate or target organizations not selected."
      end

      it "returns proper json" do
        put :remove_duplicate, :format => 'js'
        response.body.should == '{"message":"Duplicate or target organizations not selected."}'
        response.should_not be_redirect
        response.status.should == 206
      end
    end

    context "ids are the same " do
      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate, :duplicate_organization_id => 1, :target_organization_id => 1
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:error].should == "Same organizations for duplicate and target selected."
      end

      it "returns proper json" do
        put :remove_duplicate, :format => 'js', :duplicate_organization_id => 1, :target_organization_id => 1
        response.body.should == '{"message":"Same organizations for duplicate and target selected."}'
        response.should_not be_redirect
        response.status.should == 206
      end
    end

    context "merge ok" do
      let(:dupe) { FactoryGirl.create(:organization) }
      let(:target) { FactoryGirl.create(:organization) }

      before :each do
        Organization.should_receive(:merge_organizations!).with(target, dupe).and_return true
      end

      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate, :duplicate_organization_id => dupe.id,
          :target_organization_id => target.id
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:notice].should == "Organizations successfully merged."
      end

      it "responds OK (json)" do
        put :remove_duplicate, :format => 'js', :duplicate_organization_id => dupe.id,
          :target_organization_id => target.id
        response.body.should == '{"message":"Organizations successfully merged."}'
        response.should_not be_redirect
        response.status.should == 200
      end
    end
  end
end
