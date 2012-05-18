Feature: admin can see overview report
  In order to view all HRT data
  As a sysadmin
  I want to be able to see an overview report

  Background:
    Given a basic reporter setup
      And a project exists with data_response: the data_response, name: "project1"
      And a activity_fully_coded exists with data_response: the data_response, project: the project
      And an other_cost_fully_coded exists with name: "some cost", data_response: the data_response
      And an admin exists with email: "sysadmin@hrtapp.com"
     When I am signed in as "sysadmin@hrtapp.com"

  Scenario: See reporter overview
    Given an implementer_split exists with organization: the organization, activity: the activity, spend: 100, budget: 200
    And an implementer_split exists with organization: the organization, activity: the other cost, spend: 10, budget: 20
    When I follow "Reports"
    And I should see "Reporters" within "#tabs-container"
    And I should see "Funders" within "#tabs-container"
    And I should see "Locations" within "#tabs-container"
    And I should see "organization2" within "table"


