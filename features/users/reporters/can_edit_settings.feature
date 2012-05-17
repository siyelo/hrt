Feature: Reporter can manage data response
  In order to track information
  As a reporter
  I want to be able to manage data response

  Background:
    Given a basic reporter setup
    And I am signed in as "reporter@hrtapp.com"
    And I follow "Settings"

  Scenario: Reporter can edit settings
    When I select "Euro (EUR)" from "Default Currency"
      And I select "Government" from "Raw Type"
      And I should not see "Fosaid"
      And I press "Update organization"
      Then I should see "Settings were successfully updated"
