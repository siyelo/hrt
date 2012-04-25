Feature: Reporter can see org overview report
  In order to view all my data
  As an Reporter
  I want to be able to see an overview report

  Background:
    Given an organization exists with name: "Organization1", currency: "RWF"
      And a data_request exists with title: "dr1", organization: the organization
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And a project exists with data_response: the data_response
      And a classified_activity exists with data_response: the data_response, project: the project
      And an other_cost_fully_coded exists with name: "some cost", data_response: the data_response
     When I am signed in as "reporter@hrtapp.com"

  Scenario: See reports overview
    When an implementer_split exists with organization: the organization, activity: the activity, spend: 100, budget: 200
    And an implementer_split exists with organization: the organization, activity: the other cost, spend: 10, budget: 20
    When I follow "Reports"
    Then I should see "Total Expenditure" within ".reports_summary"
    And I should see "110.00" within ".reports_summary"
    Then I should see "Total Budget" within ".reports_summary"
    And I should see "220.00" within ".reports_summary"
    Then I should see "Change" within ".reports_summary"
    And I should see "100.0" within ".reports_summary"
    And I should see "Projects" within "#tabs-container"
    And I should see "Locations" within "#tabs-container"
    And I should see "Inputs" within "#tabs-container"
    And I should see "RWF" within ".summary"
    And I should see "some cost" within "table"

