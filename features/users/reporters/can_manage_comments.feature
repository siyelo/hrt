Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

  Background:
    Given a basic reporter setup
      And a project exists with name: "project1", data_response: the data_response
      And an activity exists with name: "activity1", project: the project, data_response: the data_response
      And I am signed in as "reporter@hrtapp.com"

    Scenario: Reporter can see only comments from his organization on dashboard
      Given a comment exists with comment: "comment1", commentable: the project, user: the reporter
        And a organization exists with name: "USAID"
        And a reporter exists with email: "reporter2@hrtapp.com", organization: the organization
        And a data_response should exist with data_request: the data_request, organization: the organization
        And a project exists with name: "Other Project", data_response: the data_response
        And a comment exists with comment: "comment2", commentable: the project, user: the reporter
      When I follow "Home"
      Then I should see "comment1"
        And I should not see "comment2"

    @javascript
    Scenario: Reporter can comment on a response
      When I follow "Projects"
      And I fill in "comment[comment]" with "response_comment"
        And I press "Comment"
      Then I should see "response_comment"
        And I should not see "Edit" within ".comments_list"
      When I follow "Reply" within ".comments_list"
        And I fill in "Comment" with "response_comment_reply" within ".js_reply_box"
        And I press "Reply" within ".js_reply_box"
      Then I should see "response_comment_reply"

    @javascript
    Scenario: Reporter can comment on a project
      When I follow "Projects"
        And I follow "project1"
        And I fill in "comment[comment]" with "project_comment"
        And I press "Comment"
      Then I should see "project_comment"
        And I should not see "Edit" within ".comments_list"
      When I follow "Reply" within ".comments_list"
        And I fill in "Comment" with "project_comment_reply" within ".js_reply_box"
        And I press "Reply" within ".js_reply_box"
      Then I should see "project_comment_reply"

    @javascript
    Scenario: Reporter can comment on an activity
      When I follow "Projects"
        And I follow "activity1"
        And I fill in "comment[comment]" with "activity_comment"
        And I press "Comment"
      Then I should see "activity_comment"
        And I should not see "Edit" within ".comments_list"
      When I follow "Reply" within ".comments_list"
        And I fill in "Comment" with "activity_comment_reply" within ".js_reply_box"
        And I press "Reply" within ".js_reply_box"
      Then I should see "activity_comment_reply"

    @javascript
    Scenario: Does not email users when a comment is made by a reporter
      Given a reporter exists with email: "reporter2@hrtapp.com", organization: the organization
        And a comment exists with comment: "project_comment", commentable: the project, user: the reporter
        And no emails have been sent
      When I follow "Projects"
        And I follow "project1"
        And I fill in "comment[comment]" with "project_comment_reply"
        And I press "Comment"
      Then I should see "project_comment_reply"
        And "reporter@hrtapp.com" should not receive an email
        And "reporter2@hrtapp.com" should receive an email
