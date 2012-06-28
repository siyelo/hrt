Feature: Reporter can manage projects
  In order to track information
  As a reporter
  I want to be able to manage my projects

  Background:
    Given a basic reporter setup
    And I am signed in as "reporter@hrtapp.com"
    And I follow "Projects"

  Scenario: Reporter can CRUD projects
    When I follow "Project"
    And I fill in "Name" with "Project1"
    And I fill in "Description" with "Project1 description"
    And I fill in "project[start_date]" with "2011-01-01"
    And I fill in "project[end_date]" with "2011-12-01"
    And I select "Euro (EUR)" from "Currency override"
    And I select "On-budget" from "project_budget_type"
    And I fill in "project_in_flows_attributes_0_organization_id_from" with "organization1"
    And I fill in "project_in_flows_attributes_0_spend" with "10"
    And I fill in "project_in_flows_attributes_0_budget" with "20"
    And I press "Create Project"
    Then I should see "Project successfully created"
    When I follow "Project1"
    And the "project_in_flows_attributes_0_organization_id_from" field should contain "organization1"
    And I fill in "Name" with "Project2"
    And I fill in "Description" with "Project2 description"
    And I press "Update Project"
    Then I should see "Project successfully updated"
    When I follow "Delete this Project"
    Then I should see "Project was successfully destroyed"

  Scenario Outline: Edit project dates, see feedback messages for start and end dates
    When I follow "Project"
    And I fill in "Name" with "Some Project"
    And I fill in "project[start_date]" with "<start_date>"
    And I fill in "project[end_date]" with "<end_date>"
    And I press "Create Project"
    Then I should see "<message>"
    And I should see "<specific_message>"

    Examples:
      | start_date | end_date   | message                              | specific_message                      |
      |            | 2010-01-02 | Oops, we couldn't save your changes. | Start date can't be blank             |
      | 123        | 2010-01-02 | Oops, we couldn't save your changes. | Start date is not a valid date        |
      | 2010-05-05 | 2010-01-02 | Oops, we couldn't save your changes. | Start date must come before End date. |
