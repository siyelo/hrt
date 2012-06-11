Feature: Reporter can edit profile
  In order to change my details
  As a reporter
  I want to be able to change my profile

  Background:
  Given a basic reporter setup
    And I am signed in as "reporter@hrtapp.com"

  Scenario: User can change credentials and login again
    Given I follow "My Profile"
      And I fill in "New password" with "password2"
      And I fill in "Confirm new password" with "password2"
    When I press "Save"
    Then I should see "Profile was successfully updated"
    When I fill in "Email" with "reporter@hrtapp.com"
      And I fill in "Password" with "password2"
      And I press "Sign in"
    Then I should see "Signed in successfully."

  Scenario: User can change name and email and login again without changing the password
    When I follow "My Profile"
      And I fill in "Email" with "frank@example.com"
      And I press "Save"
    Then I should see "Profile was successfully updated"
    When I follow "Sign Out"
    Then I should see "Signed out successfully."
      And I fill in "Email" with "frank@example.com"
      And I fill in "Password" with "password"
      And I press "Sign in"
    Then I should see "Signed in successfully."
