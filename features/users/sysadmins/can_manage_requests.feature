Feature: Admin can manage data requests
  In order to collect data in the system
  As a admin
  I want to be able to manage data requests

  Background:
    Given an organization exists with name: "org1", name: "coolorg"
    And a data_request exists with organization: the organization
    And an admin exists with email: "admin@hrtapp.com", organization: the organization
    And I am signed in as "admin@hrtapp.com"

    Scenario: Admin can CRUD data requests
      When I follow "Requests"
       # delete existing data request
       And I follow "Delete"
       And I follow "Create Data Request"
       Then I should see "coolorg"
       And I fill in "data_request_title" with "My data response title"
       And I fill in "data_request_start_date" with "2010-01-01"
       And I press "Create request"
      Then I should see "Request was successfully created"
       And I should see "coolorg"

      When I follow "Edit"
       And the "data_request_title" field should contain "My data response title"
       And I fill in "Title" with "My new data response title"
       And I should see "coolorg"
       And I press "Update request"
       Then I should see "Request was successfully updated"
       And I should see "My new data response title"

      When I follow "Delete"
      Then I should see "Request was successfully deleted."
       And I should not see "My data response title"

    Scenario Outline: See errors when creating data request
      When I follow "Requests"
       And I follow "Create Data Request"
       And I fill in "Title" with "<title>"
       And I fill in "Start date" with "<start_date>"
       And I press "Create request"
      Then I should see "<message>"

      Examples:
        | organization | title | start_date | message                              |
        | org1         | title | 2010-01-01 | Request was successfully created     |
        | org1         |       | 2010-01-01 | Title can't be blank         |
        | org1         | title |            | Start date can't be blank         |
        | org1         | title | 123        | Start date is not a valid date    |

