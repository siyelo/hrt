Feature: Reporter can Review & Submit response
  In order to send data information
  As a reporter
  I want to be able to Review & Submit response

  Scenario: Reporter can Review & Submit response when it's ready
    Given a basic reporter setup
      And a project exists with data_response: the data_response
      And a activity_fully_coded exists with data_response: the data_response, project: the project
      And an implementer_split exists with organization: the organization, activity: the activity, budget: 1000, spend: 1000
      And I am signed in as "reporter@hrtapp.com"
    When I follow "Projects & Activities"
      And I follow "Review & Submit"
      And I follow "Submit"
    Then I should see "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      And I should see "Submit" within ".submit"

  Scenario: Reporter cannot Submit response when it's not ready
    Given a basic reporter setup
      And a project exists with data_response: the data_response
      And I am signed in as "reporter@hrtapp.com"
    When I follow "Projects & Activities"
      And I follow "Review & Submit"
    Then I should see "Submit Response"
    When I follow "Submit"
    Then I should see "Oops, we couldn't process your submission."
      And I should see "Activites are not yet classified."
