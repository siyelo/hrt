Feature: SysAdmin can manage files
  In order to have well-formatted files
  As an sysadmin
  I want to be able to manage well-formatted files

  Background:
      And an admin exists with email: "admin@hrtapp.com"
      And I am signed in as "admin@hrtapp.com"

    Scenario: SysAdmin can manage files
      When I follow "Reports"
        And I follow "Files"
        And I follow "Create File"
        And I fill in "document_title" with "File 1"
        And I fill in "document_description" with "description of the document"
        And I attach the file "spec/fixtures/activities.csv" to "document_document"
        And I select "Public" from "document_visibility"
        And I press "Save"
        Then I should see "File was successfully uploaded."
          And I should see the image "tooltip.png"
          And I should see "File 1"
          And I should see "Public"

      When I follow "File 1"
        Then I should see the Open or Save dialog for a "csv" file

      When I go to admin files page
      And I follow "Edit"
        Then I should see "Current file: activities.csv"
        When I fill in "document_title" with "New file 1"
          And I select "Reporter" from "document_visibility"
          And I fill in "document_description" with ""
          And I press "Save"
          Then I should see "File was successfully updated."
            And I should see "New file 1"
            And I should see "Reporter"
            And I should not see the image "tooltip.png"

      When I follow "Delete"
        Then I should see "File was successfully deleted."
        And I should not see "New file 1"
