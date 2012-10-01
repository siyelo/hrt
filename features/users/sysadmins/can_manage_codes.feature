Feature: Admin can manage codes
  In order to track information
  As an admin
  I want to be able to manage codes

  Background:
    Given an organization exists with name: "organization1"
      And an admin exists with email: "admin@hrtapp.com", organization: the organization
      And I am signed in as "admin@hrtapp.com"

    Scenario: Admin can edit codes
      Given a code exists with short_display: "code1", long_display: "code1 long", official_name: "code1 official name", description: "code1 description", type: "Purpose"
      When I follow "Codes"
        And I follow "Purposes"
        And I follow "code1"
      When I fill in "Short display" with "code2"
        And I fill in "Long display" with "code2 long"
        And I fill in "Official name" with "code2 official name"
        And I fill in "Description" with "code2 description"
        And I press "Update Code"
      Then I should see "Code was successfully updated"
        And the "Short display" field should contain "code2"
        And the "Long display" field should contain "code2 long"
        And the "Official name" field should contain "code2 official name"
        And the "Description" field should contain "code2 description"
        And the "Type" field should contain "Purpose"
