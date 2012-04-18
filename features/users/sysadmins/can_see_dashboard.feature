Feature: District Manager can see dashboard
  In order to
  As an District Manager
  I want to be able to see a dashboard for relevant activities

  Scenario: See dashboard
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization
      And an sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
    When I am signed in as "sysadmin@hrtapp.com"
    Then I should see "Dashboard"
