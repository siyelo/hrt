Feature: Admin can manage currencies
  In order to track information
  As an admin
  I want to be able to manage currencies

  Background:
    Given an admin exists with email: "sysadmin@hrtapp.com"
    And I am signed in as "sysadmin@hrtapp.com"
    And I follow "Currencies"

    Scenario: Can manage currency
      When I follow "Create Currency"
      And I fill in "From" with "VEF"
      And I fill in "To" with "BWP"
      And I fill in "Rate" with "1.53423"
      And I press "Save"
      Then I should see "Currency was successfully created"
      When I follow "Edit"
      And I fill in "Rate" with "500"
      And I press "Save"
      Then I should see "Currency was successfully updated"
      And I should see "500"
      When I follow "x" within ".manage_bar"
      Then I should see "Currency was successfully destroyed"
      And I should not see "500"

    Scenario: Can search for a currency
      Given a currency exists with from: "CHF", to: "ZAR"
      And a currency exists with from: "USD", to: "ZAR"
      When I fill in "query" with "CHF"
      And I press "Search"
      And I should see "CHF"
      And I should not see "USD"

