Feature: Reporter can manage Indirect Costs
  In order to track information
  As a reporter
  I want to be able to manage Indirect Costs

  Background:
  Given a basic reporter setup
    And a project exists with name: "project1", data_response: the data_response
    And I am signed in as "reporter@hrtapp.com"
    And I follow "Projects"

  Scenario: Reporter can CRUD Indirect Costs
    When I follow "Add an Indirect Cost now"
    Then I should see "New Indirect Cost"
    When I fill in "Name" with "other_cost1"
    And I fill in "Description" with "other_cost2 description"
    And I select "project1" from "Project"
    # self org should already be present/selected
    And I fill in "other_cost[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "other_cost[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Indirect Cost was successfully created"
    And I fill in "Name" with "other_cost2"
    And I press "Save"
    Then I should see "Indirect Cost was successfully updated"
    And I follow "Projects"
    And I should see "other_cost2"
    And I should not see "other_cost1"
    When I follow "other_cost2"
    Then I should see "2 Locations"
    Then I should see "3 Inputs"
    And I follow "Delete this Indirect Cost"
    Then I should see "Indirect Cost was successfully destroyed"
    And I should not see "other_cost1"
    And I should not see "other_cost2"

  Scenario: Reporter can create an Indirect Cost at an Org level (i.e. without a project)
    When I follow "Add an Indirect Cost now"
    And I fill in "Name" with "other_cost1"
    And I fill in "Description" with "other_cost1"
    # self org should already be selected
    And I fill in "other_cost[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "other_cost[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Indirect Cost was successfully created"
