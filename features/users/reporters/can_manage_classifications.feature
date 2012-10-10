Feature: Reporter can enter a code breakdown for each activity
  In order to increase the quality of information reported
  As a reporter
  I want to be able to break down activities into individual codes

  Background:
  # Given the following code structure
  #
  #         / code111
  #    / code11 - code112
  # code1
  #    \ code12 - code121
  #         \ code122
  #
  #         / code211
  #    / code21 - code212
  # code2
  #    \ code22 - code221
  #         \ code222

    # level 1
    Given a basic reporter setup
    Given a purpose "purpose1" exists with id: 1, name: "purpose1"
      And a purpose "purpose2" exists with id: 2, name: "purpose2"
      And a input exists with id: 3, name: "cost_category1"
      And a project exists with name: "Project", data_response: the data_response
      And I am signed in as "reporter@hrtapp.com"


    ############
    ### PURPOSES
    ############
    Scenario: Reporter can classify Purposes for activity (first level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      #since we used a FactoryGirl.create above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][purpose][budget][1]" with "100"
      And I fill in "activity[classifications][purpose][spend][1]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      And the "activity[classifications][purpose][budget][1]" field should contain "100"
      And the "activity[classifications][purpose][spend][1]" field should contain "100"


    Scenario: Reporter can classify Purposes for activity (second level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And a purpose "purpose11" exists with id: 11, name: "purpose11", parent: purpose "purpose1"
      And a purpose "purpose12" exists with id: 12, name: "purpose12", parent: purpose "purpose1"
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][purpose][budget][11]" with "40"
      And I fill in "activity[classifications][purpose][spend][11]" with "60"
      And I fill in "activity[classifications][purpose][budget][12]" with "60"
      And I fill in "activity[classifications][purpose][spend][12]" with "40"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      And the "activity[classifications][purpose][budget][11]" field should contain "40"
      And the "activity[classifications][purpose][spend][11]" field should contain "60"
      And the "activity[classifications][purpose][budget][12]" field should contain "60"
      And the "activity[classifications][purpose][spend][12]" field should contain "40"

    Scenario: Reporter can classify Purposes for activity (third level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And a purpose "purpose11" exists with id: 11, name: "purpose11", parent: purpose "purpose1"
      And a purpose "purpose12" exists with id: 12, name: "purpose12", parent: purpose "purpose1"
      And a purpose "purpose111" exists with id: 111, name: "purpose111", parent: purpose "purpose11"
      And a purpose "purpose112" exists with id: 112, name: "purpose112", parent: purpose "purpose11"
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][purpose][budget][111]" with "40"
      And I fill in "activity[classifications][purpose][spend][111]" with "60"
      And I fill in "activity[classifications][purpose][budget][112]" with "60"
      And I fill in "activity[classifications][purpose][spend][112]" with "40"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      And the "activity[classifications][purpose][budget][111]" field should contain "40"
      And the "activity[classifications][purpose][spend][111]" field should contain "60"
      And the "activity[classifications][purpose][budget][112]" field should contain "60"
      And the "activity[classifications][purpose][spend][112]" field should contain "40"

    # Because of javascript driver issue this scenario fails, marked as @wip
    # @javascript
    Scenario: Reporter can classify Purposes for activity (third level)
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And a purpose "purpose11" exists with id: 11, name: "purpose11", parent: purpose "purpose1"
      And a purpose "purpose12" exists with id: 12, name: "purpose12", parent: purpose "purpose1"
      And a purpose "purpose111" exists with id: 111, name: "purpose111", parent: purpose "purpose11"
      And a purpose "purpose112" exists with id: 112, name: "purpose112", parent: purpose "purpose11"
      And I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"

      When I fill in "activity[classifications][purpose][budget][111]" with "40"
      # Then the "activity[classifications][purpose][budget][11]" field should contain "40"
      # And the "activity[classifications][purpose][budget][1]" field should contain "40"

      When I fill in "activity[classifications][purpose][spend][111]" with "40"
      # Then the "activity[classifications][purpose][spend][11]" field should contain "40"
      # And the "activity[classifications][purpose][spend][1]" field should contain "40"

      When I fill in "activity[classifications][purpose][spend][1]" with "100"
      And I fill in "activity[classifications][purpose][budget][1]" with "100"
      # And I hover over ".tooltip" within ".values"
      # Then I should see "This amount is not the same as the sum of the amounts underneath (100.00% - 40.00% = 60%)"

      When I fill in "activity[classifications][purpose][spend][1]" with "10"
      # And I hover over ".tooltip" within ".values"
      # Then I should see "The root nodes do not add up to 100%"
      When I press "Save"
      # And I confirm the popup dialog
      Then I should not see "Activity classification was successfully updated."


    Scenario: Reporter classify Purposes for activity and see flash error
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      #since we used a FactoryGirl.create above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Purposes" within ".section_nav"
      Then the "spend_purposes" checkbox should not be checked
      And the "budget_purposes" checkbox should not be checked
      When I fill in "activity[classifications][purpose][budget][1]" with "99"
      And I fill in "activity[classifications][purpose][spend][1]" with "99"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And the "spend_purposes" checkbox should not be checked
      And the "budget_purposes" checkbox should not be checked
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][purpose][budget][1]" with "100"
      And I fill in "activity[classifications][purpose][spend][1]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      When I refresh the page
      Then I should see "This Activity has not been fully classified"
      Then the "spend_purposes" checkbox should be checked
        And the "budget_purposes" checkbox should be checked

    Scenario: Reporter classify Locations for other cost
      Given an other cost exists with name: "othercost1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the other_cost
      And a location exists with name: "National", id: 5
      When I follow "Projects"
      And I follow "othercost1"
      #since we used a FactoryGirl.create above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Locations" within ".section_nav"
      Then the "spend_locations" checkbox should not be checked
      And the "budget_locations" checkbox should not be checked
      When I fill in "other_cost[classifications][location][budget][5]" with "100"
      And I fill in "other_cost[classifications][location][spend][5]" with "100"
      And I press "Save"
      Then I should see "Indirect Cost was successfully updated."
      When I refresh the page
      Then the "spend_locations" checkbox should be checked
        And the "budget_locations" checkbox should be checked

    @javascript
    Scenario: Reporter can copy Purposes from Current Budget to Past Expenditure
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][purpose][budget][1]" with "100"
      And I follow "Copy across Budget classifications to Expenditure classifications"
      And I press "Save"
      And the "activity[classifications][purpose][budget][1]" field should contain "100"
      And the "activity[classifications][purpose][spend][1]" field should contain "100"

    @javascript
    Scenario: Reporter can copy Purposes from Past Expenditure to Current Budget
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Purposes" within ".section_nav"
      And I fill in "activity[classifications][purpose][spend][1]" with "100"
      And I follow "Copy across Expenditure classifications to Budget classifications"
      And I press "Save"
      And the "activity[classifications][purpose][budget][1]" field should contain "100"
      And the "activity[classifications][purpose][spend][1]" field should contain "100"


    ############
    ### INPUTS
    ############
    Scenario: Reporter can enter Inputs for activity
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Inputs" within ".section_nav"
      And I fill in "activity[classifications][input][budget][3]" with "100"
      And I fill in "activity[classifications][input][spend][3]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
        And I should not see "Purposes by Current Budget are not classified and Purposes by Past Expenditure are not classified"
      When I refresh the page
      Then the "activity[classifications][input][budget][3]" field should contain "100"
        And the "activity[classifications][input][spend][3]" field should contain "100"

    Scenario: Reporter can enter Inputs for activity and see flash error
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
      And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
      And I follow "activity1"
      #since we used a FactoryGirl.create above, need save to refresh cache by saving activity
      And I press "Save"
      And I follow "Inputs" within ".section_nav"
      And I fill in "activity[classifications][input][budget][3]" with "99"
      And I fill in "activity[classifications][input][spend][3]" with "99"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      And the "spend_inputs" checkbox should not be checked
      And the "budget_inputs" checkbox should not be checked
      When I follow "Projects"
      And I follow "activity1"
      And I follow "Inputs" within ".section_nav"
      And I fill in "activity[classifications][input][budget][3]" with "100"
      And I fill in "activity[classifications][input][spend][3]" with "100"
      And I press "Save"
      Then I should see "Activity was successfully updated."
      When I refresh the page
      Then the "spend_inputs" checkbox should be checked
        And the "budget_inputs" checkbox should be checked

    Scenario: Reporter can follow classification workflow for activity
      Given an activity exists with name: "activity1", data_response: the data_response, project: the project
        And an implementer_split exists with budget: "5000000", spend: "6000000", organization: the organization, activity: the activity
      When I follow "Projects"
        And I follow "activity1"
      When I press "Save & Add Locations >"
        And I press "Save & Add Purposes >"
        And I press "Save & Add Inputs >"
        And I press "Save & Add Outputs, Targets & Beneficiaries >"
        And I press "Save & Go to Overview >"
      Then I should see "data_request1" within "#projects_listing h1"

    Scenario: Reporter can follow Indirect Costs workflow for other cost
      Given an other cost exists with name: "OC1", data_response: the data_response, project: the project
      When I follow "Projects"
        And I follow "OC1"
      When I press "Save & Add Locations >"
        And I press "Save & Add Inputs >"
        And I press "Save & Go to Overview >"
      Then I should see "data_request1" within "#projects_listing h1"
