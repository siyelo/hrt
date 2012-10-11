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
      FactoryGirl.create :user, organization: organization #+1 R
      FactoryGirl.create :organization # +1 NR
    end

    it "displays reporting organization by default" do
      get :index
      assigns(:organizations).size.should == 2
    end

    it "ignores bad filters " do
      get :index, filter: 'blargh'
      assigns(:organizations).size.should == 2
    end

    it "filters by non-reporting" do
      get :index, filter: "Non-Reporting"
      assigns(:organizations).size.should == 3
    end

    it "filters by all" do
      get :index, filter: "All"
      assigns(:organizations).size.should == 5
    end
  end

  it "#show(s)" do
    organization = FactoryGirl.create(:organization)
    organization2 = FactoryGirl.create(:organization)
    get :show, id: organization.id, duplicate_id: organization2.id
    assigns(:target).should == organization
    assigns(:duplicate).should == organization2
  end

  describe "#destroy" do
    before :each do
      basic_setup_implementer_split_for_controller
      Organization.should_receive(:find).and_return @organization
    end

    it "sets flash notice" do
      @organization.should_receive(:destroy).and_return(true)
      delete :destroy, id: @organization.id
      flash[:notice].should == "Organization was successfully destroyed."
      response.should redirect_to(admin_organizations_url)
    end

    it "sets flash errror" do
      @organization.should_receive(:destroy).and_return(false)
      delete :destroy, id: @organization.id
      flash[:error].should == "You cannot delete an organization that has (external) data referencing it."
      response.should redirect_to(admin_organizations_url)
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
    end

    context "ids are the same " do
      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate, duplicate_organization_id: 1, target_organization_id: 1
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:error].should == "Same organizations for duplicate and target selected."
      end
    end

    context "duplicate has responses but target doesn't" do
      it "redirects to the duplicate_admin_organizations_path" do
        target = FactoryGirl.create(:organization)
        duplicate = FactoryGirl.create(:organization)
        FactoryGirl.create(:user, organization: duplicate)
        duplicate.reload

        put :remove_duplicate, :duplicate_organization_id => duplicate.id,
          :target_organization_id => target.id
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:error].should == "An organization with responses cannot be merged into an organization without responses.  Try swap the duplicate and target organizations"
      end
    end

    context "merge ok" do
      let(:dupe) { FactoryGirl.create(:organization) }
      let(:target) { FactoryGirl.create(:organization) }

      before :each do
        Organization.should_receive(:merge_organizations!).with(target, dupe).and_return true
      end

      it "redirects to the duplicate_admin_organizations_path" do
        put :remove_duplicate, duplicate_organization_id: dupe.id,
          target_organization_id: target.id
        response.should redirect_to(duplicate_admin_organizations_path)
        flash[:notice].should == "Organizations successfully merged."
      end

      it "responds OK (js)" do
        put :remove_duplicate, format: 'js', duplicate_organization_id: dupe.id,
          target_organization_id: target.id
        response.should render_template('remove_duplicate_notice')
        response.should_not be_redirect
        response.status.should == 200
      end
    end
  end
end
