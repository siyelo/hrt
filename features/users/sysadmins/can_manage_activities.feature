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

    Scenario: An admin can create comments for an activity
      When I follow "Responses"
        And I follow "organization2: data_request1"
        And I follow "activity2"
        And I fill in "Comment" with "Comment body"
        And I press "Create Comment"
      Then I should see "Comment body"
        # confirm being on the activity edit form
        And the "Name" field should contain "activity2"

    @javascript
    Scenario: An admin can approve classified activity and still edit it
      Given an activity exists with name: "activity1", description: "a1 description", data_response: the data_response, project: the project
      When I follow "Responses"
        And I follow "organization2: data_request1"
        And I follow "activity1"
        And I follow "Approve (Admin)"
        And I follow "Approve Budget"
        And wait a few moments
        Then I should see "Admin Approved"
        And I should see "Budget Approved"

      When I fill in "Name" with "activity1 edited"
      And I press "Save"
      Then the "Name" field should contain "activity1 edited"

    @javascript
    Scenario: An admin cannot approve unclassified activity
      When I follow "Responses"
        And I follow "organization2: data_request1"
        And I follow "activity2"
        And I press "Save"
        And I follow "Approve (Admin)"
        And wait a few moments
      Then I should not see "Admin Approved"
