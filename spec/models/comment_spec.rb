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
    it "returns all comment" do
      request       = FactoryGirl.create :data_request
      organization1 = FactoryGirl.create :organization
      organization2 = FactoryGirl.create :organization
      FactoryGirl.create :user, organization: organization1
      FactoryGirl.create :user, organization: organization2
      response1     = organization1.latest_response
      response2     = organization2.latest_response

      project       = FactoryGirl.create(:project, data_response: response1)
      activity      = FactoryGirl.create(:activity, data_response: response1,
                                         project: project)
      other_cost    = FactoryGirl.create(:other_cost, data_response: response1,
                                         project: project)
      reporter      = FactoryGirl.create(:reporter, organization: organization1)

      response_comment       = FactoryGirl.create(:comment,
                                commentable: response1, user: reporter)
      project_comment        =  FactoryGirl.create(:comment,
                                 commentable: project, user: reporter)
      activity_comment       =  FactoryGirl.create(:comment,
                                 commentable: activity, user: reporter)
      other_cost_comment     = FactoryGirl.create(:comment,
                                 commentable: other_cost, user: reporter)
      old_response_comment   = FactoryGirl.create(:comment,
                                 commentable: response2, user: reporter)

      comments = Comment.on_all([response1.id])

      comments.should include(response_comment)
      comments.should include(project_comment)
      comments.should include(activity_comment)
      comments.should include(other_cost_comment)
      comments.should_not include(old_response_comment)
    end
  end
end
