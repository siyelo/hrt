Feature: Visitor can download public files
  In order to view data
  As a visitor
  I want to be able to download public files

  Background:
    Given a document exists with title: "My file", visibility: "public"

    Scenario: Visitor can download files
      When I go to the home page
        And I follow "My file"
      Then I should see the Open or Save dialog for a "csv" file
