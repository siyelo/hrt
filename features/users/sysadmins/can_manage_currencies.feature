Feature: Admin can manage currencies
  In order to track information
  As an admin
  I want to be able to manage currencies

  Background:
    Given now is "12-12-2011 08:31:00 +0000"
    And an admin exists with email: "sysadmin@hrtapp.com"
    And I am signed in as "sysadmin@hrtapp.com"
    And I follow "Currencies"

    Scenario: Can add currency and delete it
      When I follow "Create Currency"
      And I fill in "From" with "VEF"
      And I fill in "To" with "bwp"
      And I fill in "Rate" with "1.53423"
      And I press "Save"
      Then I should see "You have successfully added a currency"
      And I fill in "query" with "BWP"
      And I press "Search"
      And I should see "BWP"
      And I should see "VEF"
      And I should see "1.53423"
      And I should see "12 Dec 2011"
      When I follow "x"
      And I should not see "1.53423"

