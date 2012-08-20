Feature: Activity Manager can see dashboard
  In order to see an overview of the data
  As a Activity Manager
  I want to be able to see a dashboard

  Background:
    Given an organization "admin_org" exists with name: "admin_org"
      And a data_request exists with organization: the organization
      And an organization "reporter_org" exists with name: "reporter_org"
      And a reporter exists with organization: the organization "reporter_org", email: "reporter@hrtapp.com"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And the data_response state is: "submitted"
      And an organization "ac_org" exists with name: "ac_org"
      And an activity_manager exists with email: "activity_manager@hrtapp.com", organization: the organization "ac_org"
      And organization "reporter_org" is one of the activity_manager's organizations
      And I am signed in as "activity_manager@hrtapp.com"

  Scenario: See dashboard
    Then I should see "Organizations I Manage"
      And I should see "There are no comments posted in the last 6 months."
      And I should see "There are no files available for download."

  @javascript
  Scenario: Can reject with response with a reason
    When I follow "Reject"
      And I fill in "comment[comment]" with "Rejection reason" within ".simple_overlay"
      And I press "Reject"
    Then wait a few moments
      And I should see "Response rejected: Rejection reason"
