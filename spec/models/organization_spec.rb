require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:raw_type) }
    it { should allow_mass_assignment_of(:implementer_type) }
    it { should allow_mass_assignment_of(:funder_type) }
    it { should allow_mass_assignment_of(:fosaid) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:fiscal_year_end_date) }
    it { should allow_mass_assignment_of(:fiscal_year_start_date) }
    it { should allow_mass_assignment_of(:contact_name) }
    it { should allow_mass_assignment_of(:contact_position) }
    it { should allow_mass_assignment_of(:contact_phone_number) }
    it { should allow_mass_assignment_of(:contact_main_office_phone_number) }
    it { should allow_mass_assignment_of(:contact_office_location) }
  end

  describe "Associations" do
    it { should have_many(:activities) }
    it { should have_many(:users) }
    it { should have_many(:data_requests) }
    it { should have_many(:data_responses).dependent(:destroy) }
    it { should have_many(:projects) }
    it { should have_many(:dr_activities) }
    it { should have_many(:out_flows) }
    it { should have_many(:donor_for) }
    it { should have_many(:implementer_splits) }
    it { should have_and_belong_to_many :managers }
  end

  describe "Validations" do
    subject { Factory(:organization) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:raw_type) }
    it { should validate_uniqueness_of(:name) }

    it "is valid when currency is included in the list" do
      organization = Factory.build(:organization, :currency => 'USD')
      organization.save
      organization.errors.on(:currency).should be_blank
    end
  end

  describe "custom date validations" do
    it { should allow_mass_assignment_of(:fiscal_year_start_date) }
    it { should allow_mass_assignment_of(:fiscal_year_end_date) }
    it { should allow_mass_assignment_of(:contact_name) }
    it { should allow_mass_assignment_of(:contact_position) }
    it { should allow_mass_assignment_of(:contact_phone_number) }
    it { should allow_mass_assignment_of(:contact_main_office_phone_number) }
    it { should allow_mass_assignment_of(:contact_office_location) }
    it { should allow_value('2010-12-01').for(:fiscal_year_start_date) }
    it { should allow_value('2010-12-01').for(:fiscal_year_end_date) }

    it "accepts start date < end date (exactly 1 year)" do
      organization = Factory.build(:organization,
                                   :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                                   :fiscal_year_end_date =>   DateTime.new(2010, 12, 31) )
      organization.should be_valid
    end

    it "does not accept an end date that is not one year after the start date" do
      organization = Factory.build(:organization,
                                   :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                                   :fiscal_year_end_date =>   DateTime.new(2010, 12, 30) )
      organization.should_not be_valid
    end

    it "does not accept start date > end date" do
      organization = Factory.build(:organization,
                                   :fiscal_year_start_date => DateTime.new(2010, 01, 02),
                                   :fiscal_year_end_date =>   DateTime.new(2009, 01, 01) )
      organization.should_not be_valid
    end

    it "does not accept start date = end date" do
      organization = Factory.build(:organization,
                                   :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                                   :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      organization.should_not be_valid
    end
  end

  describe "named_scopes" do
    it "order organizations by name" do
      org1 = Factory(:organization, :name => 'Org2')
      org2 = Factory(:organization, :name => 'Org1')

      Organization.ordered.should == [org2, org1]
    end

    # integration test
    it "finds all reporting orgs" do
      user = Factory :user
      Organization.reporting.should == [user.organization]
    end

    # integration test
    it "finds all nonreporting orgs" do
      organization = Factory(:organization)
      Organization.nonreporting.should == [organization]
    end
  end

  describe 'reporting/non-reporting' do
    it "is non-reporting if no users" do
      org = Organization.new
      org.reporting?.should == false
    end

    it "is non-reporting if no users" do
      org = Organization.new
      org.stub(:users_count).and_return 1
      org.reporting?.should == true
    end
  end

  describe "#create_data_responses!" do
    let(:org_requester) { Factory(:organization) }
    let(:request) { Factory(:data_request, :organization => org_requester) }
    let(:user) { Factory :user } # callback does the work
    let(:organization) { user.organization.reload }

    it "creates data_responses for each data_request unless a response exists" do
      request.reload # instantiate the request
      organization.responses.map(&:data_request).should include(request)
    end

    it "does not create new data_responses if response exists" do
      request.reload
      organization.responses.count.should == 1
      organization.create_data_responses!
      organization.responses.count.should == 1
    end
  end

  describe "#last logged in user" do
    before :each do
      @org = Factory.build(:organization)
      @user = Factory.build(:user,
                            :last_login_at => DateTime.parse('2009-05-04 02:00:00'),
                            :current_login_at => DateTime.parse('2009-06-04 02:00:00'))
      @org.users << @user
    end

    it "returns the last user in that organization that logged in if there is one user" do
      @org.current_user_logged_in.should == @user
    end

    it "returns nil when nobody has ever logged in" do
      @user.last_login_at = nil
      @user.current_login_at = nil
      user2 = Factory.build(:user, :organization => @org)
      @org.users << @user; @org.users << user2
      @org.current_user_logged_in.should be_nil
    end

    # authlogic idiosyncracy
    it " returns last logged in as nil on first sign in" do
      @user.last_login_at = nil
      @org.current_user_logged_in.should == @user
    end
  end

  describe "creating a organization record" do
    before :each do
      basic_setup_project
    end

    it "can have many out_flows" do
      @organization.out_flows.should have(0).items
      Factory(:funding_flow,
              :project => @project, :from => @organization)
      @organization.reload
      @organization.out_flows.should have(1).item
    end

    it "can donate to a project" do
      @organization.donor_for.should have(0).items
      Factory(:funding_flow,
              :project => @project, :from => @organization)
      @organization.reload
      @organization.donor_for.should have(1).item
    end
  end

  describe "CSV" do
    before :each do
      @organization = Factory(:organization, :name => 'blarorg', :raw_type => 'NGO', :fosaid => "13")
    end

    it "will return just the headers if no organizations are passed" do
      org_headers = Organization.download_template
      org_headers.should == "name,raw_type,fosaid,currency\n"
    end

    it "will return a list of organizations if there are present" do
      organizations = Organization.all
      orgs = Organization.download_template(organizations)
      orgs.should == "name,raw_type,fosaid,currency\nblarorg,NGO,13,USD\n"
    end
  end


  describe "remove duplicate organization" do
    before :each do
      @organization       = Factory(:organization)
      Factory(:data_request, :organization => @organization)
      @target_org         = Factory(:organization, :name => "Target org")
      @duplicate_org      = Factory(:organization, :name => "Duplicate org")
      @target_org_user    = Factory(:user, :organization => @target_org)
      @duplicate_org_user = Factory(:user, :organization => @duplicate_org)
      @target_response    = @target_org.reload.latest_response
      @duplicate_response = @duplicate_org.reload.latest_response
      Factory(:data_request, :organization => @organization)
      @target_response2    = @target_org.latest_response
      @duplicate_response2 = @duplicate_org.latest_response
    end

    it "should move users" do
      Organization.merge_organizations!(@target_org, @duplicate_org)
      @target_org.users.should == [@target_org_user, @duplicate_org_user]
      @target_org.reload.users.should == [@target_org_user, @duplicate_org_user]
      @target_org.users_count.should == @target_org.users.size
    end

    it "deletes duplicate after merge" do
      Organization.merge_organizations!(@target_org, @duplicate_org)
      all_organizations = Organization.all
      all_organizations.should include(@target_org)
      all_organizations.should_not include(@duplicate_org)
    end

    it "moves projects from duplicate to target organization" do
      project1 = Factory(:project, :data_response => @duplicate_response)
      project2 = Factory(:project, :data_response => @duplicate_response2)

      Organization.merge_organizations!(@target_org, @duplicate_org)
      all_organizations = Organization.all
      @target_response.projects.should include(project1)
      @target_response2.projects.should include(project2)
      all_organizations.should include(@target_org)
      all_organizations.should_not include(@duplicate_org)
    end

    it "copies also invalid data responses from duplicate to @target" do
      @duplicate_org.fiscal_year_start_date = "2010-02-01"
      @duplicate_org.fiscal_year_end_date = "2010-01-01"
      @duplicate_org.save(false)
      duplicate_data_response = @duplicate_org.latest_response
      Organization.merge_organizations!(@target_org, @duplicate_org)
      @target_org.data_responses.count.should == 2 # not 2, since our before block created a valid DR
    end

    it "moves activities from duplicate to target organization" do
      project1 = Factory(:project, :data_response => @duplicate_response)
      project2 = Factory(:project, :data_response => @duplicate_response2)
      activity1 = Factory(:activity, :data_response => @duplicate_response,
                          :project => project1)
      activity2 = Factory(:activity, :data_response => @duplicate_response2,
                          :project => project2)

      Organization.merge_organizations!(@target_org, @duplicate_org)
      @target_response.activities.should include(activity1)
      @target_response2.activities.should include(activity2)
      activity1.project.should == project1
      activity2.project.should == project2
    end

    it "should move other costs without a project" do
      oc = Factory(:other_cost_fully_coded, :data_response => @duplicate_response)
      Organization.merge_organizations!(@target_org, @duplicate_org)
      @target_response.other_costs.should include(oc)
      oc.reload
      oc.organization.should == @target_org
      oc.data_response.should == @target_response
    end

    context "when referenced" do
      before :each do
        organization  = Factory(:organization, :name => "other org")
        user = Factory :user, :organization => organization
        data_response = organization.latest_response
        @other_project = Project.new(:data_response => data_response,
                                     :name => "p1",
                                     :currency => "USD",
                                     :description => "proj descr",
                                     :start_date => "2010-01-01",
                                     :end_date => "2011-01-01",
                                     :in_flows_attributes => [
                                       :organization_id_from => @duplicate_org.id,
                                       :budget => 10, :spend => 20])
        @other_project.save!
        @other_activity = Factory(:activity, :data_response => data_response,
                                  :project => @other_project)
        split = Factory(:implementer_split, :activity => @other_activity,
                        :organization => @duplicate_org)
        @other_activity.reload.save #recalculates IS total of activity
      end

      it "should point funder references to new target org" do
        Organization.merge_organizations!(@target_org, @duplicate_org)
        @other_project.reload.in_flows.first.from.should == @target_org
        @target_org.out_flows.should == [@other_project.in_flows.first]
      end

      it "should point implementer references to new target org" do
        @other_activity.implementer_splits.first.organization.should == @duplicate_org
        Organization.merge_organizations!(@target_org, @duplicate_org)
        @other_activity.reload.implementer_splits.first.organization.should == @target_org
      end
    end
  end

  describe "counter cache" do
    it "caches users count" do
      o = Factory :organization
      o.users_count.should == 0
      Factory :reporter, :organization => o
      o.reload.users_count.should == 1
    end

    it "should update users count when user is moved to other organization" do
      o1       = Factory(:organization)
      o2       = Factory(:organization)
      reporter = Factory(:reporter, :organization => o1)
      reporter.organization.should == o1
      o1.reload.users_count.should == 1
      o2.reload.users_count.should == 0
      reporter.organization_id = o2.id
      reporter.save!
      reporter.reload.organization.should == o2
      o1.reload.users_count.should == 0
      o2.reload.users_count.should == 1
    end
  end

  describe "associations" do
    describe "#organization_managers" do
      before :each do
        @organization = Factory(:organization)
      end

      it "should only return activity managers from the organization passed to it" do
        u1 = Factory(:reporter, :organization => @organization)
        u2 = Factory(:sysadmin, :organization => @organization)
        u3 = Factory(:activity_manager, :organization => @organization)
        u3.organizations << @organization
        @organization.managers.should include(u3)
        @organization.managers.should_not include(u1)
        @organization.managers.should_not include(u2)
      end

      it "should return all activity managers from the organization passed to it" do
        u1 = Factory(:reporter, :organization => @organization)
        u2 = Factory(:sysadmin, :organization => @organization)
        u3 = Factory(:activity_manager, :organization => @organization)
        u4 = Factory(:activity_manager, :organization => @organization)
        u3.organizations << @organization; u4.organizations << @organization
        @organization.managers.should include(u3)
        @organization.managers.should include(u4)
        @organization.managers.should_not include(u1)
        @organization.managers.should_not include(u2)
      end

      it "should return activity managers that are able to manage the organization even if they aren't part of it" do
        org = Factory(:organization)
        u1 = Factory(:reporter, :organization => @organization)
        u2 = Factory(:sysadmin, :organization => @organization)
        u3 = Factory(:activity_manager, :organization => org)
        u3.organizations << @organization
        @organization.managers.should include(u3)
        @organization.managers.should_not include(u1)
        @organization.managers.should_not include(u2)
      end

    end
  end

  describe "latest_response" do
    before :each do
      @req = Factory :request
      @user = Factory :user
      @org = @user.organization
    end
    it "should return the last data response that was created on this org" do
      @org.latest_response.request.should == @req
    end

    it "should return nil if there is no response, though this means the Org is invalid!!" do
      @org.responses.each {|r| r.destroy}
      @org.reload
      @org.latest_response.should == nil
    end
  end

  describe "#user_emails" do
    it "should return email addresses of users in the organization, up to the limit" do
      @req = Factory :request
      @org = Factory :organization
      @reporter = Factory :reporter, :email => 'reporter@org.com', :organization => @org
      @reporter2 = Factory :reporter, :email => 'reporter2@org.com', :organization => @org
      @org.user_emails(1).should == ['reporter@org.com']
    end
  end

  describe "#destroy" do
    it "should allow deletion if they have not created any requests" do
      basic_setup_implementer_split
      @response.submit!
      @organization.latest_response.status.should == "Submitted"
      result = @organization.destroy
      @organization.errors.on(:base).should == nil
      result.should be_true
    end

    it "should allow deletion if they have non-project costs. FIXME: see #19381309" do
      basic_setup_implementer_split
      oc = Factory(:other_cost_fully_coded, :data_response => @response) # non-project OC
      @response.submit!
      @organization.latest_response.status.should == "Submitted"
      result = @organization.destroy
      @organization.errors.on(:base).should == nil
      result.should be_true
    end

    describe "internal vs external Funder references" do
      it "should allow deletion when only self-Funder references exist" do
        basic_setup_project
        result = @organization.destroy
        @organization.errors.on(:base).should == nil
        result.should be_true
      end

      it "should not allow deletion when external Funder references exist" do
        basic_setup_project
        user1 = Factory :user
        org1 = user1.organization
        proj1 = Factory(:project, :data_response => org1.latest_response)
        ff1 = Factory(:funding_flow, :project => proj1, :from => @organization)
        @organization.destroy.should be_false
        @organization.errors.on(:base).should include "Cannot delete organization with (external) Funder references"
      end

      it "should allow deletion when only internal Funder references exist" do
        basic_setup_project
        self_funded(@project)
        @project.in_flows.first.destroy #at this point, proj is self-funded
        @organization.destroy.should be_true
      end

      def setup_a_project_that_references_funder(funder)
        user = Factory :user
        organization = user.organization
        response     = organization.latest_response
        project      = Project.new(:data_response => response,
                                   :name => "non_factory_project_name_#{rand(100_000_000)}",
                                   :description => "proj descr",
                                   :currency => "USD",
                                   :start_date => "2010-01-01",
                                   :end_date => "2011-01-01",
                                   :in_flows_attributes => [:organization_id_from => funder.id,
                                     :budget => 10, :spend => 20])
        project.save!
      end

      it "should not allow deletion when both internal & external Funder references exist" do
        basic_setup_project
        self_funded(@project)
        setup_a_project_that_references_funder(@organization)
        @organization.destroy.should be_false
        @organization.errors.on(:base).should include "Cannot delete organization with (external) Funder references"
      end
    end

    describe "internal vs external Implementer references" do
      it "should not allow deletion when external Implementer references exist (and no Purpose splits exist)" do
        basic_setup_implementer_split # nb: sets up a self-implementer
        other_org    = Factory(:organization)
        @implementer_split = Factory(:implementer_split,
                                     :activity => @activity, :organization => other_org)
        other_org.destroy.should be_false
        other_org.errors.on(:base).should include "Cannot delete organization with (external) Implementer references"
      end

      it "should allow deletion when only internal Implementer references exist" do
        basic_setup_implementer_split
        @split.organization = @organization
        @split.save!
        result = @organization.destroy
        @organization.errors.on(:base).should == nil
        result.should be_true
      end

      def setup_an_activity_that_references_implementer(implementer)
        user = Factory :user
        organization = user.organization
        data_response = organization.latest_response
        project      = Factory(:project, :data_response => data_response)
        activity     = Factory(:activity, :data_response => data_response, :project => project)
        split = Factory(:implementer_split, :activity => activity,
                        :organization => implementer)
        activity.save! #recalculate implementer split total on activity
      end

      it "should not allow deletion when both internal & external Funder references exist" do
        basic_setup_implementer_split
        setup_an_activity_that_references_implementer(@organization)
        @organization.destroy.should be_false
        @organization.errors.on(:base).should include "Cannot delete organization with (external) Implementer references"
      end
    end
  end
end
