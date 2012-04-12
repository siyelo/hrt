Feature: Admin can manage files
  In order to have well-formatted files
  As an sysadmin
  I want to be able to manage well-formatted files

  Background:
    Given an organization exists with name: "organization1"
      And a data_request exists with title: "data_request1", organization: the organization
      And an admin exists with email: "admin@hrtapp.com", organization: the organization
      And I am signed in as "admin@hrtapp.com"

    Scenario: Admin can manage files
      When I follow "Reports"
        And I follow "Files"
        And I follow "Create File"
        And I fill in "document_title" with "File 1"
        And I attach the file "spec/fixtures/activities.csv" to "document_document"
        And I press "Save"
        Then I should see "File was successfully uploaded."
          And I should see "File 1"

      When I follow "Edit"
        And I fill in "document_title" with "New file 1"
        And I press "Save"
        Then I should see "File was successfully updated."
        Then I should see "New file 1"

      When I follow "Delete"
        Then I should see "File was successfully deleted."
        And I should not see "New file 1"
