Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

  Background:
    Given a basic reporter setup
      And a project exists with name: "project1", data_response: the data_response
      And a comment exists with comment: "comment1", commentable: the project
      And I am signed in as "reporter@hrtapp.com"

    Scenario: See latest comments on dashboard
      When I follow "Home"
      Then I should see "Recent Comments"
        And I should see "comment1"

    Scenario: Reporter can see only comments from his organization
      Given a organization exists with name: "USAID"
        And a reporter exists with email: "reporter2@hrtapp.com", organization: the organization
        And a data_response should exist with data_request: the data_request, organization: the organization
        And a project exists with name: "Other Project", data_response: the data_response
        And a comment exists with comment: "comment2", commentable: the project, user: the reporter
      When I follow "Home"
      Then I should see "comment1"
        And I should not see "comment2"
