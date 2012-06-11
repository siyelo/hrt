Feature: Reporter can download files
  In order to view data
  As an reporter
  I want to be able to download files

  Background:
    Given a basic reporter setup
      And a document exists with title: "My file", visibility: "reporters"
      And I am signed in as "reporter@hrtapp.com"
      And I follow "Reports"
      And I follow "Files"

    Scenario: Reporter can download files
      When I follow "My file"
      Then I should see the Open or Save dialog for a "csv" file

      When I go to the dashboard
        And I follow "view all" within "#documents"
        And I follow "My file"
      Then I should see the Open or Save dialog for a "csv" file
