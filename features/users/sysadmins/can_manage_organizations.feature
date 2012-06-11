Feature: Admin can manage organizations
  In order to save time and avoid user revolt
  As an admin
  I want to be able to manage organizations

  Background:
    Given now is "01-01-2011 21:30:00 +0000"
    Given an organization exists with name: "org1", raw_type: "Donor", fosaid: "111"
    And a data_request exists with title: "Req1", organization: the organization
    And an admin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And a location exists with short_display: "All"
    Given now is "01-06-2011 21:30:00 +0000"
    And an organization exists with name: "org2", raw_type: "Ngo", fosaid: "222"
    And a reporter exists with email: "org2_user@hrtapp.com", organization: the organization
    Given now is "12-12-2011 08:30:00 +0000"
    And I am signed in as "sysadmin@hrtapp.com"
    And I follow "Organizations"

  Scenario: Admin can CRUD organizations
    Given I follow "Create Organization"
    And I fill in "organization_name" with "Organization name"
    And I select "Bilateral" from "Raw Type"
    And I fill in "organization_implementer_type" with "Implementer"
    And I fill in "organization_funder_type" with "Donor"
    And I fill in "organization_fosaid" with "123"
    And I fill in "organization_contact_name" with "Pink"
    And I fill in "organization_contact_position" with "The man"
    And I fill in "organization_contact_phone_number" with "34234234"
    And I fill in "organization_contact_main_office_phone_number" with "34234234"
    And I fill in "organization_contact_office_location" with "Japan"
    And I press "Create organization"
    Then I should see "Organization was successfully created"
    And the "organization[name]" field should contain "Organization name"
    And the "organization[fosaid]" field should contain "123"
    And the "Raw Type" field should contain "Bilateral"
    And the "organization[implementer_type]" field should contain "Implementer"
    And the "organization[funder_type]" field should contain "Donor"
    And the "organization[contact_name]" field should contain "Pink"
    And the "organization[contact_position]" field should contain "The man"
    And the "organization[contact_phone_number]" field should contain "34234234"
    And the "organization[contact_main_office_phone_number]" field should contain "34234234"
    And the "organization[contact_office_location]" field should contain "Japan"

    When I fill in "organization_name" with "My new organization"
    And I press "Update organization"
    Then I should see "Organization was successfully updated"
    And the "organization[name]" field should contain "My new organization"
    When I follow "Delete this Organization"
    Then I should see "Organization was successfully destroyed"
    And I should not see "Organization name"
    And I should not see "My new organization"

  # This spec is throwing a java.util.ConcurrentModificationException on some
  # environments (usually locally)
  # Potentially fixed in JRuby 1.6.4 ?  http://jruby.org/2011/08/22/jruby-1-6-4.html
  # Also noted here: http://jira.codehaus.org/browse/JRUBY-5209?page=com.atlassian.streams.streams-jira-plugin%3Aactivity-stream-issue-tab#issue-tabs
  @javascript @wip
  Scenario Outline: Merge duplicate organizations
    Given an organization exists with name: "org3"
    And I follow "Fix duplicate organizations"
    And I select "<duplicate>" from "Potential problem organization (duplicate)"
    And I select "<target>" from "Replacement organization"
    And I press "Replace"
    Then I should see "<message>"

    Examples:
      | duplicate      | target         | message                                               |
      | Org3 - 0 users | Org3 - 0 users | Same organizations for duplicate and target selected. |
      | Org3 - 0 users | Org2 - 1 user  | Organizations successfully merged.                    |

  @javascript
  Scenario Outline: Merge duplicate organizations (with JS)
    Given an organization exists with name: "org3"
    And I follow "Fix duplicate organizations"
    Then I should see "Potential problem organization (duplicate)"
    And I should see "Replacement organization"
    Then I should see "Duplicate Org1"
    And I should see "Replacement Org1"
    And I should see "Merged Org1"

  Scenario Outline: An admin can sort organizations
    And I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text1>"
    And column "<column>" row "2" should have text "<text2>"
    When I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text2>"
    And column "<column>" row "2" should have text "<text1>"

    Examples:
      | column_name  | column | text1 | text2 |
      | Organization | 1      | org2  | org1  |
      | Type         | 4      | Donor | Ngo   |

  Scenario: An admin can search organizations
    Then I should see "org1"
    And I should see "org2"
    And I fill in "query" with "org1"
    And I press "Search"
    And I should see "org1" within "table"
    And I should not see "org2" within "table"

  Scenario: An admin can sort by created at
    When I follow "Created" within the table heading
    Then I should see "org2" within a link in the 1st row of the table

  Scenario: can see correct listing columns
    When I follow "Sign Out"
    Given now is "12-12-2011 08:31:00 +0000"
    And I am signed in as "org2_user@hrtapp.com"
    And I follow "Sign Out"
    Given now is "12-12-2011 08:32:00 +0000"
    And I am signed in as "sysadmin@hrtapp.com"
    When I follow "Organizations"
    Then I should see "Organization" within the table heading
    And I should see "Last Login By" within the table heading
    And I should see "Last Login At" within the table heading
    And I should see "Type" within the table heading
    And I should see "FOSAID" within the table heading
    And I should see "Created" within the table heading
    And I should see "org2" within a link in the 2nd row of the table
    And I should see "Some Reporter" within a link in the 2nd row of the table
    And I should see "12 Dec '11 08:31" within the 2nd row of the table
    And I should see "Ngo" within the 2nd row of the table
    And I should see "222" within the 2nd row of the table
    And I should see "01 Jun '11" within the 2nd row of the table

  Scenario: An admin can see an organization's users
    When I follow "Edit" within a link in the 1st row of the table
    Then I should see "Users"
    And I should see "sysadmin@hrtapp.com"

  Scenario: admin can see available filters
     Then I should see "Reporting"
     Then I should see "Non-Reporting"
     And I should see "All"

  Scenario: Sysadmin can filter organizations by type
    Given an organization exists with name: "No user org"
    And I follow "Organizations"
    Then I should see "org2"
      And I should not see "No user org"
    When I follow "Non-Reporting" within ".section_nav"
    Then I should see "No user org"
      And I should not see "org2"
    When I follow "All" within ".section_nav"
    Then I should see "org2"
      And I should see "No user org"
    When I follow "Reporting" within ".section_nav"
    Then I should see "org2"
      And I should not see "No user org"
