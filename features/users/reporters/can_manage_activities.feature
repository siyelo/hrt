Feature: Reporter can manage activities
  In order to track information
  As a reporter
  I want to be able to manage activities

  Background:
    Given a basic reporter setup
    And a project exists with name: "project1", data_response: the data_response
    And I am signed in as "reporter@hrtapp.com"
    And I follow "Projects"

  Scenario: Reporter can CRUD activities
    When I follow "Add Activities now"
    And I fill in "activity_name" with "activity1"
    And I fill in "activity_description" with "activity1 description"
    And I select "project1" from "Project"
    # self org should already be present/selected
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Activity was successfully created"
    And I fill in "Name" with "activity2"
    And I fill in "Description" with "activity2 description"
    And I press "Save"
    Then I should see "Activity was successfully updated"
    And I follow "Projects"
    When I follow "activity2"
    And I follow "Delete this Activity"
    Then I should see "Activity was successfully destroyed"

  @javascript
  Scenario: Reporter can add targets & outputs
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I follow "5 Outputs, Targets & Beneficiaries"
    And I follow "Add Target"
    And I fill in "target_field" with "Target description"
    And I follow "Add Output"
    And I fill in "output_field" with "Output description"
    And I press "Save"
    Then I should see "Activity was successfully updated"
    And the "target_field" field should contain "Target description"
    And the "output_field" field should contain "Output description"

  Scenario: Reporter can add implementers with percentages
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I follow "Implementers" within ".section_nav"
    And I fill in "activity_implementer_splits_attributes_0_organization_mask" with "organization2"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I press "Save"
    Then I should see "Activity was successfully updated."
    And the "activity[implementer_splits_attributes][0][spend]" field should contain "99"
    And the "activity[implementer_splits_attributes][0][budget]" field should contain "19"

  Scenario: Reporter can see error message when adding duplicate implementers to new activity
    When I follow "Add Activities now"
    And I fill in "activity_name" with "activity1"
    And I fill in "activity_description" with "activity1 description"
    And I select "project1" from "Project"
    # self org should already be present/selected
    And I fill in "activity_implementer_splits_attributes_0_organization_mask" with "organization2"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I fill in "activity_implementer_splits_attributes_1_organization_mask" with "organization2"
    And I fill in "activity[implementer_splits_attributes][1][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][1][budget]" with "19"
    And I press "Save"
    Then I should see "Duplicate Implementer"

  Scenario: Reporter can see error message when adding duplicate implementers to existing activity
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I follow "Implementers" within ".section_nav"
    And I fill in "activity_implementer_splits_attributes_0_organization_mask" with "organization2"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][0][budget]" with "19"
    And I fill in "activity_implementer_splits_attributes_1_organization_mask" with "organization2"
    And I fill in "activity[implementer_splits_attributes][1][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][1][budget]" with "19"
    And I press "Save"
    Then I should see "Duplicate Implementer"

  Scenario: Reporter can see live total being updated
    Given an activity exists with project: the project, name: "existing activity", description: "existing description", data_response: the data_response
    When I follow "Projects"
    And I follow "existing activity"
    And I fill in "activity[implementer_splits_attributes][0][spend]" with "99"
    And I fill in "activity[implementer_splits_attributes][1][spend]" with "100"
