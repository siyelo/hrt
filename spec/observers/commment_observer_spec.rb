require File.dirname(__FILE__) + '/../spec_helper'

describe CommentObserver do
  ### unit tests

  ### integration tests
  describe "Notifications" do
    before :each do
      requesting_org = FactoryGirl.create(:organization, name: "Requester")
      reporting_org = FactoryGirl.create(:organization, name: "Responder")
      am_organization = FactoryGirl.create(:organization, name: "ActivityManagers")
      @admin        = FactoryGirl.create(:sysadmin, organization: requesting_org)
      @act_manager  = FactoryGirl.create(:activity_manager,
        organization: am_organization,
        organizations: [reporting_org])
      @act_manager2 = FactoryGirl.create(:activity_manager,
        organization: am_organization,
        organizations: [reporting_org])
      @reporter1    = FactoryGirl.create(:reporter, organization: reporting_org,
                              email: 'reporter1@hrt.com')
      @reporter2    = FactoryGirl.create(:reporter, organization: reporting_org,
                              email: 'reporter2@hrt.com')
      request       = FactoryGirl.create(:data_request, organization: requesting_org)
      response      = reporting_org.latest_response
      @project      = FactoryGirl.create(:project, data_response: response)
    end

    context "root comment (without parent_id)" do
      it "should notify users in same org when commenter is also in that org" do
        reset_mailer
        FactoryGirl.create(:comment, commentable: @project, user: @reporter1)
        unread_emails_for(@admin.email).size.should == 0
        unread_emails_for(@reporter1.email).size.should == 0
        unread_emails_for(@reporter2.email).size.should == 1
      end

      it "should notify users in target org when commenter is admin" do
        reset_mailer
        FactoryGirl.create(:comment, commentable: @project, user: @admin)
        unread_emails_for(@admin.email).size.should == 0
        unread_emails_for(@reporter1.email).size.should == 1
        unread_emails_for(@reporter2.email).size.should == 1
        unread_emails_for(@act_manager.email).size.should == 0 #sanity
        unread_emails_for(@act_manager2.email).size.should == 0 #sanity
      end

      it "should notify users in target org when commenter is admin" do
        reset_mailer
        FactoryGirl.create(:comment, commentable: @project, user: @act_manager)
        unread_emails_for(@admin.email).size.should == 0
        unread_emails_for(@act_manager.email).size.should == 0
        unread_emails_for(@act_manager2.email).size.should == 0
        unread_emails_for(@reporter1.email).size.should == 1
        unread_emails_for(@reporter2.email).size.should == 1
      end
    end

    context "reply comment (with parent_id)" do
      it "should not notify anyone when reporter1 comments again" do
        reset_mailer
        comment1 = FactoryGirl.create(:comment, commentable: @project,
                           user: @reporter1)
        reset_mailer
        FactoryGirl.create(:comment, commentable: @project,
                user: @reporter1, parent: comment1)
        unread_emails_for(@reporter1.email).size.should == 0
        unread_emails_for(@reporter2.email).size.should == 0
        unread_emails_for(@admin.email).size.should == 0
      end

      it "should notify reporter 1 when  reporter2 responds" do
        reset_mailer
        comment1 = FactoryGirl.create(:comment, commentable: @project,
                           user: @reporter1)
        reset_mailer
        FactoryGirl.create(:comment, commentable: @project,
                user: @reporter2, parent: comment1)
        unread_emails_for(@reporter1.email).size.should == 1
        unread_emails_for(@reporter2.email).size.should == 0
        unread_emails_for(@admin.email).size.should == 0
      end
    end
  end
end
