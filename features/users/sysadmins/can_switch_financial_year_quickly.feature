Feature: SysAdmin can switch financial year quickly
  In order to access previous year's data
  As an sysadmin
  I want to be able to switch financial year quickly

  Background:
    Given an organization exists with name: "SysAdmin Organization"
      And a data_request exists with title: "data_request1", organization: the organization, start_date: "2010-01-01", end_date: "2011-01-01"
      And a data_request exists with title: "data_request2", organization: the organization, start_date: "2011-01-01", end_date: "2012-01-01"
      And an admin exists with email: "admin@hrtapp.com", organization: the organization

      And an organization exists with name: "Reporter Organization"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization


      And I am signed in as "admin@hrtapp.com"

    Scenario: SysAdmin can switch financial year on report's dashboard
      Then I should see "data_request2"
      When I follow "Previous Request"
      Then I should see "data_request1"
      When I follow "Next Request"
      Then I should see "data_request2"
