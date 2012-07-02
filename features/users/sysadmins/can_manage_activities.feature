Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given a basic reporter setup
      And an sysadmin exists with email: "sysadmin@hrtapp.com"
      And a project exists with name: "project2", data_response: the data_response
      And an activity exists with name: "activity2", description: "activity2 description", project: the project, data_response: the data_response
      And an implementer_split exists with budget: "2", spend: "2", organization: the organization, activity: the activity
      And I am signed in as "sysadmin@hrtapp.com"

    Scenario: An admin can review activities
      When I follow "Responses"
      And I follow "organization2: data_request1"
        And I follow "activity2"
      Then the "Name" field should contain "activity2"
        And the "Description" field should contain "activity2 description"
      When I follow "Delete this Activity"
      Then I should see "Activity was successfully destroyed"

    Scenario: An admin can edit activity
      When I follow "Responses"
        And I follow "organization2: data_request1"
        And I follow "activity2"
        And I fill in "Name" with "activity2 edited"
        And I fill in "Description" with "activity2 description edited"
        And I press "Save"
      Then the "Name" field should contain "activity2 edited"
        And the "Description" field should contain "activity2 description edited"
