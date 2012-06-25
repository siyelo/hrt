Feature: Admin can manage data responses
  In order to classify valid data
  As an admin
  I want to be able to manage data responses

  Background:
    Given an organization exists with name: "UNDP"
      And a data_request exists with organization: the organization, title: "FY2010-11 Expenditures and FY2011-12 Budget"
      And a reporter exists with email: "reporter1@hrtapp.com", organization: the organization, full_name: "joe"
      And a reporter exists with email: "reporter2@hrtapp.com", organization: the organization, full_name: "bob"
      And a data_response should exist with data_request: the data_request, organization: the organization
      And a project exists with data_response: the data_response
      And a activity_fully_coded exists with project: the project, data_response: the data_response
      And a sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
      And I am signed in as "sysadmin@hrtapp.com"

    Scenario: SysAdmin can see status change dropdown
      Given the data_response state is: "started"
      When I follow "Responses"
        And I follow "Started"
        And I follow "UNDP: FY2010-11 Expenditures"
      Then I should see "Status: Started" within "#state"
        And I should see "Accept" within "#state ul"
        And I should see "Reject" within "#state ul"

    Scenario: SysAdmin can approve response
      Given the data_response state is: "submitted"
      When I follow "Responses"
        And I follow "Submitted"
        And I follow "UNDP: FY2010-11 Expenditures"
      Then I should see "Status: Submitted" within "#state"
        When I follow "Accept" within "#state"
      Then I should see "Response was successfully accepted"
        And I should see "Status: Accepted" within "#state"
      When "reporter1@hrtapp.com" open the email with subject "Your UNDP: FY2010-11 Expenditures and FY2011-12 Budget response is Accepted"
      Then I should see "Your submission has been reviewed and accepted." in the email body

    Scenario: SysAdmin can reject response
      Given the data_response state is: "submitted"
      When I follow "Responses"
        And I follow "Submitted"
        And I follow "UNDP: FY2010-11 Expenditures"
      Then I should see "Status: Submitted" within "#state"
        When I follow "Reject" within "#state"
      Then I should see "Response was successfully rejected"
        And I should see "Status: Rejected" within "#state"
      When "reporter1@hrtapp.com" open the email with subject "Your UNDP: FY2010-11 Expenditures and FY2011-12 Budget response is Rejected"
      Then I should see "We have reviewed your submission and noted some issues that you need to correct" in the email body

  Scenario: can create response
    Given an organization exists with name: "MegaCorp"
    When I follow "Responses"
     And I follow "Create Response"
     And I select "MegaCorp" from "Organization"
     And I select "FY2010-11 Expenditures and FY2011-12 Budget" from "Request"
     And I press "Save"
    Then I should see "Response was successfully created"
    And I should see "MegaCorp: FY2010-11 Expenditures and FY2011-12 Budget"
