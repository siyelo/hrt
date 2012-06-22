Feature: Activity Manager can see dashboard
  In order to see an overview of the data
  As a Activity Manager
  I want to be able to see a dashboard

  Background:
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization
      And an organization exists
      And an activity_manager exists with email: "activity_manager@hrtapp.com", organization: the organization
      And I am signed in as "activity_manager@hrtapp.com"

  Scenario: See dashboard
    Then I should see "Organizations I Manage"
      And I should see "There are no comments posted in the last 6 months."
      And I should see "There are no files available for download."
