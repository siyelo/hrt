Feature: Reporter can see dashboard
  In order to see an overview of the data
  As a Reporter
  I want to be able to see a dashboard

  Background:
    Given a basic reporter setup
      And I am signed in as "reporter@hrtapp.com"

  Scenario: See menu tabs when a Data Req is selected
    Then I should see "Home" within the main nav
      And I should see "Projects" within the main nav
      And I should see "Reports" within the main nav
      And I should see "Settings" within the main nav
      And I should see "Total Expenditure USD 0.00"
      And I should see "Total Budget USD 0.00"
      And I should see "Response Status Not Yet Started"
      And I should see "There are no comments posted in the last 6 months."
      And I should see "There are no files available for download."
