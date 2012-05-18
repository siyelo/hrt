Feature: Admin can view reports
  In order to view all system data
  As an Admin
  I want to be able to see an overview report

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And an sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
     When I am signed in as "sysadmin@hrtapp.com"

  Scenario: See reports->dynamic
    When I follow "Reports"
    And I follow "Dynamic"
    And I should see "data_request1"
    Then I should see "Dynamic Reports"
    And I should see "Generate combined (Expenditures and Budgets)" within ".data"
    When I follow "Generate combined (Expenditures and Budgets)"
    Then I should see "Export combined (Expenditures and Budgets)"

  Scenario: See reports -> files
    When I follow "Reports"
    And I follow "Files"
    Then I should see "Files"

