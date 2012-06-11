require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:comment) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should_not allow_mass_assignment_of(:user_id) }
    it { should_not allow_mass_assignment_of(:commentable_id) }
    it { should_not allow_mass_assignment_of(:commentable_type) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }
  end

  describe "Validations" do
    it { should validate_presence_of :comment }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :commentable_id }
    it { should validate_presence_of :commentable_type }
  end

  describe "Named scopes" do
    it "returns all comment in the last 6 monts" do
      request      = FactoryGirl.create :data_request
      organization = FactoryGirl.create :organization
      FactoryGirl.create :user, :organization => organization
      response     = organization.latest_response
      project      = FactoryGirl.create(:project, :data_response => response)
      activity     = FactoryGirl.create(:activity, :data_response => response, :project => project)
      other_cost   = FactoryGirl.create(:other_cost, :data_response => response, :project => project)
      reporter     = FactoryGirl.create(:reporter, :organization => organization)

      Timecop.freeze(Date.parse("2010-09-01"))

      response_comment       = FactoryGirl.create(:comment, :commentable => response,
                                       :user => reporter, :created_at => "2010-08-01")
      project_comment        =  FactoryGirl.create(:comment, :commentable => project,
                                       :user => reporter, :created_at => "2010-08-01")
      activity_comment       =  FactoryGirl.create(:comment, :commentable => activity,
                                       :user => reporter, :created_at => "2010-08-01")
      other_cost_comment     = FactoryGirl.create(:comment, :commentable => other_cost,
                                       :user => reporter, :created_at => "2010-08-01")

      old_response_comment   = FactoryGirl.create(:comment, :commentable => response,
                                       :user => reporter, :created_at => "2010-02-01")
      old_project_comment    = FactoryGirl.create(:comment, :commentable => project,
                                       :user => reporter, :created_at => "2010-02-01")
      old_activity_comment   = FactoryGirl.create(:comment, :commentable => activity,
                                       :user => reporter, :created_at => "2010-02-01")
      old_other_cost_comment = FactoryGirl.create(:comment, :commentable => other_cost,
                                       :user => reporter, :created_at => "2010-02-01")

      comments = Comment.on_all([response.id])

      comments.should include(response_comment)
      comments.should include(project_comment)
      comments.should include(activity_comment)
      comments.should include(other_cost_comment)

      comments.should_not include(old_response_comment)
      comments.should_not include(old_project_comment)
      comments.should_not include(old_activity_comment)
      comments.should_not include(old_other_cost_comment)
    end
  end
end
