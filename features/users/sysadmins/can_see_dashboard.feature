Feature: Sysadmin can see dashboard
  In order to see an overview of the data
  As an Sysadmin
  I want to be able to see a dashboard

  Background:
    Given an organization exists
      And a data_request exists with title: "dr1", organization: the organization
      And an sysadmin exists with email: "sysadmin@hrtapp.com", organization: the organization
      And I am signed in as "sysadmin@hrtapp.com"

  Scenario: See dashboard
    Then I should see "Dashboard"
      And I should see "Current Request dr1"
      And I should see "Not Yet Started 100%"
      And I should see "Accepted 0%"
      And I should see "Started 0%"
      And I should see "Pending Approval 0"
      And I should see "No responses have been submitted yet."
      And I should see "There are no comments posted in the last 6 months."
      And I should see "There are no files available for download."
