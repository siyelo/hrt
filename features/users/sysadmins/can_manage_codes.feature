Feature: Admin can manage codes
  In order to track information
  As an admin
  I want to be able to manage codes

  Background:
    Given an organization exists with name: "organization1"
      And an admin exists with email: "admin@hrtapp.com", organization: the organization
      And I am signed in as "admin@hrtapp.com"

    Scenario: Admin can CRUD codes
      Given a code exists with short_display: "code1", long_display: "code1 long", official_name: "code1 official name", description: "code1 description", type: "Mtef"
      When I follow "Codes"
        And I follow "code1"
      When I fill in "Short display" with "code2"
        And I fill in "Long display" with "code2 long"
        And I fill in "Official name" with "code2 official name"
        And I fill in "Description" with "code2 description"
        And I press "Update Code"
      Then I should see "Code was successfully updated"
        And the "Short display" field should contain "code2"
        And the "Long display" field should contain "code2 long"
        And the "Official name" field should contain "code2 official name"
        And the "Description" field should contain "code2 description"
        And the "Type" field should contain "Mtef"

    Scenario: Adding malformed CSV file doesnt throw exception
      When I follow "Codes"
        And I attach the file "spec/fixtures/malformed.csv" to "File"
        And I press "Upload and Import"
      Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"

    Scenario: Admin can upload codes
      When I follow "Codes"
        And I attach the file "spec/fixtures/codes.csv" to "File"
        And I press "Upload and Import"
      Then I should see "Created 4 of 4 codes successfully"
        And I should see "code1"
        And I should see "code2"
        And I should see "code3"
        And I should see "code4"

    Scenario: Admin can see error if no csv file is not attached for upload
      When I follow "Codes"
        And I press "Upload and Import"
      Then I should see "Please select a file to upload"

    Scenario: Admin can see error when invalid csv file is attached for upload and download template
      When I follow "Codes"
        And I attach the file "spec/fixtures/invalid.csv" to "File"
        And I press "Upload and Import"
      Then I should see "Wrong fields mapping. Please download the CSV template"

      When I follow "Download template"
      Then I should see "short_display,long_display,description,type,external_id,parent_short_display,hssp2_stratprog_val,hssp2_stratobj_val,official_name,sub_account,nha_code,nasa_code"
