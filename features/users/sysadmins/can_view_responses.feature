Feature: Admin can view responses
  In order to save time and view user data
  As an admin
  I want to be able to view responses

  Background:
    Given an organization exists with name: "org1", raw_type: "Donor", fosaid: "111"
    And a data_request exists with title: "Req1", organization: the organization
    And an admin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And an organization exists with name: "org2"
    And a reporter exists with email: "org2_user@hrtapp.com", organization: the organization
    And I am signed in as "sysadmin@hrtapp.com"
    And I follow "Responses"

  Scenario Outline: Sysadmin can sort resopnses
    When I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text1>"
    And column "<column>" row "2" should have text "<text2>"
    When I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text2>"
    And column "<column>" row "2" should have text "<text1>"

    Examples:
      | column_name  | column | text1 | text2 |
      | Organization | 1      | org2  | org1  |

  Scenario: Sysadmin can search responses
    Then I should see "org1"
    And I should see "org2"
    And I fill in "query" with "org1"
    And I press "Search"
    And I should see "org1" within "table"
    And I should not see "org2" within "table"

  Scenario: admin can see available filters
    Then I should see "Reporting" within a link in the filters list
    And I should see "Not Yet Started" within a link in the filters list
    And I should see "Started" within a link in the filters list
    And I should see "Submitted" within a link in the filters list
    And I should see "Rejected" within a link in the filters list
    And I should see "Accepted" within a link in the filters list
    And I should see "Non-Reporting" within a link in the filters list
    And I should see "All" within a link in the filters list

  Scenario: Sysadmin can filter organizations by response status
    Given the latest response for "org2" is submitted
    Then I follow "Submitted"
    Then I should not see "org1" within "table"
    And I should see "org2" within "table"

  Scenario: Sysadmin sees only reporting orgs by default
    Given an organization exists with name: "some clinic", raw_type: "Clinic/Cabinet Medical"
    And I follow "Responses"
    Then I should not see "some clinic"

  Scenario: Sysadmin can view non-reporting orgs
    Given an organization exists with name: "some clinic", raw_type: "Clinic/Cabinet Medical"
    When I follow "Non-Reporting"
    Then I should see "some clinic"

  Scenario: See pie chart
    Then I should see "Response Status" within "#reports-summary"
