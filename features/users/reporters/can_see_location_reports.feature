Feature: Reporter can see location report
  In order to view locational data
  As an Reporter
  I want to be able to see a location report

  Background:
    Given a location exists with short_display: "Some Loc"
      And an organization exists with name: "Organization1", currency: "RWF"
      And a data_request exists with title: "dr1", organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with data_response: the data_response
      And an activity exists with name: "Act1", data_response: the data_response, project: the project
     When I am signed in as "reporter@hrtapp.com"

  @javascript
  Scenario: See locations overview
    When an implementer_split exists with organization: the organization, activity: the activity, spend: 120, budget: 220
    And a 100% location split exists with activity: "Act1", location: "Some Loc", spend_percentage: 100, budget_percentage: 100
    When I follow "Reports"
    And I follow "Locations"
    And I should see "Some Loc"
    And I should see "120" within "table"
    And I should see "220" within "table"


