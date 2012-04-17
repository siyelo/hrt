Feature: Reporter can download files
  In order to view data
  As an reporter
  I want to be able to download files

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And a document exists with title: "My file", visibility: "reporters"
      And a reporter exists with email: "reporter@hrtapp.com", organization: the organization
      And I am signed in as "reporter@hrtapp.com"

    Scenario: Reporter Admin can download files
      When I follow "My file"
      Then I should see the Open or Save dialog for a "csv" file

      When I go to the dashboard
        And I follow "view all" within ".files_read_more"
        Then I should be on the the files page
        And I follow "My file"
      Then I should see the Open or Save dialog for a "csv" file
