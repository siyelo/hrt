require 'spec_helper'

describe CommentsController do

  describe "#edit" do
    before :each do
      @organization = FactoryGirl.create(:organization, name: "Org")
      @data_request = FactoryGirl.create(:data_request,
                                         organization: @organization)
      @user = FactoryGirl.create(:reporter, organization: @organization)
    end

    it "requires logged in user" do
      get :edit, id: 1
      response.should redirect_to(root_url)
    end

    it "prevents commenter from editing the comment" do
      comment = FactoryGirl.create(:comment,
                   user: @user, commentable: @organization.data_responses.first)
      login(@user)

      get :edit, id: comment.id
      response.status.should == 401
    end

    it "allows sysadmin to edit the comment" do
      sysadmin = FactoryGirl.create(:sysadmin, organization: @organization)
      comment = FactoryGirl.create(:comment,
                   commentable: @organization.data_responses.first)
      login(sysadmin)

      get :edit, id: comment.id
      response.should render_template("form")
    end
  end

  describe "#update" do
    before :each do
      @organization = FactoryGirl.create(:organization, name: "Org")
      @data_request = FactoryGirl.create(:data_request,
                                         organization: @organization)
      @user = FactoryGirl.create(:reporter, organization: @organization)
    end

    it "prevents commenter from update the comment" do
      comment = FactoryGirl.create(:comment,
                   user: @user, commentable: @organization.data_responses.first)
      login(@user)

      put :update, {id: comment.id,
            comment: {commentable_type: comment.commentable.class.name,
                    commentable_id: comment.commentable.id}}
      response.status.should == 401
    end

    it "allows sysadmin to update the comment" do
      sysadmin = FactoryGirl.create(:sysadmin, organization: @organization)
      comment = FactoryGirl.create(:comment,
                   commentable: @organization.data_responses.first)
      login(sysadmin)

      put :update, {id: comment.id,
            comment: {commentable_type: comment.commentable.class.name,
                    commentable_id: comment.commentable.id}}
      response.should render_template("comment")
    end
  end

  describe "#destroy" do
    before :each do
      @organization = FactoryGirl.create(:organization, name: "Org")
      @data_request = FactoryGirl.create(:data_request,
                                         organization: @organization)
      @user = FactoryGirl.create(:reporter, organization: @organization)
    end

    it "prevents commenter from deleting the comment" do
      comment = FactoryGirl.create(:comment,
                   user: @user, commentable: @organization.data_responses.first)
      login(@user)

      delete :destroy, id: comment.id
      response.status.should == 401
      comment.removed.should be_false
    end

    it "allows sysadmin to update the comment" do
      sysadmin = FactoryGirl.create(:sysadmin, organization: @organization)
      comment = FactoryGirl.create(:comment,
                   commentable: @organization.data_responses.first)
      login(sysadmin)

      delete :destroy, id: comment.id
      JSON.parse(response.body)['html'].should == Comment::REMOVED_MESSAGE
      comment.removed.should be_false
    end
  end
end
