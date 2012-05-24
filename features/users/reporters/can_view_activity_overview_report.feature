Feature: Reporter can see activity overview report
  In order to view all my data
  As an Reporter
  I want to be able to see an overview report

  Background:
    Given a basic reporter setup
    And a project exists with data_response: the data_response, name: "Project1"
    And a activity_fully_coded exists with data_response: the data_response, project: the project, name: "Activity1"
     When I am signed in as "reporter@hrtapp.com"

  Scenario: See reports overview
    Given an organization exists with name: "Implementer1"
    And an implementer_split exists with organization: the organization, activity: the activity, spend: 150, budget: 300
    When I follow "Reports"
    And I follow "Project1"
    And I follow "Activity1"
    Then I should see "Implementer1" within "table"
    And I should see "Total Expenditure" within ".reports_summary"
    And I should see "150.00" within ".reports_summary"
    And I should see "Total Budget" within ".reports_summary"
    And I should see "300.00" within ".reports_summary"
    And I should see "Change" within ".reports_summary"
    And I should see "100.0" within ".reports_summary"
    And I should see "Implementers" within "#tabs-container"
    And I should see "Locations" within "#tabs-container"
    And I should see "Inputs" within "#tabs-container"
    And I should see "USD"
    And I should see "Total" within "table"
