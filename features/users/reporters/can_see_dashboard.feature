Feature: Reporter can see dashboard
  In order to see latest news
  As a reporter
  I want to be able to see a dashboard for relevant activities

  Background:
    Given a basic reporter setup
      And I am signed in as "reporter@hrtapp.com"

    Scenario: "See data requests"
      Then I should see "Dashboard"

    Scenario: See menu tabs when a Data Req is selected
      Then I should see "Home" within the main nav
        And I should see "Projects" within the main nav
        And I should see "Reports" within the main nav
        And I should see "Settings" within the main nav
