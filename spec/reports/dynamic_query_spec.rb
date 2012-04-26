require File.dirname(__FILE__) + '/../spec_helper'

describe Reports::DynamicQuery do
  def run_report
    report = Reports::DynamicQuery.new(@request, :budget)
    csv = report.csv
    table = []
    FasterCSV.parse(csv, :headers => true) { |row| table << row }
    return table
  end

  context "simple reports" do
    before :each do
      basic_setup_response
      @response.state = 'accepted'
      @response.save
      in_flows       = [Factory.build :funding_flow, :from => @organization,
        :budget => 100]
      @project      = Factory :project, :data_response => @response,
        :name => 'project',
        :in_flows => in_flows
      @project.save!
      @root_code = Factory :code
      @code1          = Factory :code, :official_name => "root"
      @activity      = Factory :activity, :project => @project,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @activity, :organization => @organization, :budget => 100
      @mtef = Factory :mtef_code, :short_display => "sub_prog_name"
      @nsp = Factory :nsp_code, :short_display => "Nsp_code"
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @nsp.move_to_child_of(@mtef)
      @code1.move_to_child_of(@nsp)
      @activity.reload;@activity.save
    end

    it "should return a 1 funder, 1 implementer report" do
      table = run_report
      table[0]['Data Source'].should == @organization.name
      table[0]['Funding Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Project'].should == @project.name
      table[0]['Description of Project'].should == @project.description
      table[0]['Activity'].should == @activity.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "100.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should adjust total amount if there are 2 funders" do
      @funder2 = Factory :organization, :name => "zz_funder"
      @project.in_flows << [Factory.build :funding_flow, :from => @funder2,
        :budget => 50]

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "66.67"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '66.67'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '66.67'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "66.67"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @funder2.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "33.33"
      table[1]['Cost Category Split %'].should == "100.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '33.33'
      table[1]['Purpose Split %'].should == "100.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "Nsp_code"
      table[1]['Location Split Total %'].should == '33.33'
      table[1]['Location Split %'].should == "100.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "33.33"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should adjusted total amount if there is 2 organizations and 2 implementers splits" do
      @funder2 = Factory :organization
      @is2 = Factory :implementer_split, :activity => @activity,
        :organization => @funder2, :budget => 100

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "100.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is2.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "100.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "100.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "Nsp_code"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "100.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "100.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end
  end

  context "complex reports" do
    before :each do
      basic_setup_response
      @response.state = 'accepted'
      @response.save
      in_flows       = [Factory.build :funding_flow, :from => @organization,
        :budget => 100]
      @project      = Factory :project, :data_response => @response,
        :name => 'project',
        :in_flows => in_flows
      @root_code = Factory :code
      @code1          = Factory :code, :official_name => "root"
      @activity      = Factory :activity, :project => @project,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @activity,
        :organization => @organization, :budget => 100
      @mtef = Factory :mtef_code, :short_display => "sub_prog_name"

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @code1.move_to_child_of(@mtef)
      @activity.reload;@activity.save
    end

    it "should adjust the total amounts as per codings (2 cost categorys splits)" do
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 25, :activity => @activity, :code => @code1
      @cost_categorization1 = Factory :coding_budget_cost_categorization,
        :percentage => 75, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1
      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "75.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "75.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "25.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "100.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "100.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "25.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should adjust the total amounts as per codings (2 coding budget splits)" do
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 80,
        :activity => @activity, :code => @code1
      @coding_budget1 = Factory :coding_budget,
        :percentage => 20, :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1
      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "80.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "80.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "100.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "20.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "100.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "20.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should adjust the total amounts as per codings (2 location budget splits)" do
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 70, :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 30, :activity => @activity, :code => @code1
      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "70.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "70.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "100.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "100.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "30.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "30.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should adjust the total amounts as per codings (2 of each budget splits)" do
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 90, :activity => @activity, :code => @code1
      @cost_categorization1 = Factory :coding_budget_cost_categorization,
        :percentage => 10, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 80,
        :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 20,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 70, :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 30, :activity => @activity, :code => @code1

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "90.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "80.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "70.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "50.40"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "90.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "80.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "30.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "21.60"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s

      table[2]['Funding Source'].should == @organization.name
      table[2]['Data Source'].should == @organization.name
      table[2]['Implementer'].should == @is.organization.name
      table[2]['Description of Activity'].should == @activity.description
      table[2]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[2]['Cost Category Split Total %'].should == "100.0"
      table[2]['Cost Category Split %'].should == "90.0"
      table[2]['Cost Category'].should == @cost_categorization.code.short_display
      table[2]['Purpose Split Total %'].should == '100.0'
      table[2]['Purpose Split %'].should == "20.0"
      table[2]['MTEF Code'].should == "sub_prog_name"
      table[2]['NSP Code'].should == "N/A"
      table[2]['Location Split Total %'].should == '100.0'
      table[2]['Location Split %'].should == "70.0"
      table[2]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[2]['Total Amount ($)'].should == "12.60"
      table[2]['Actual Double Count'].should == @is.double_count?.to_s

      table[3]['Funding Source'].should == @organization.name
      table[3]['Data Source'].should == @organization.name
      table[3]['Implementer'].should == @is.organization.name
      table[3]['Description of Activity'].should == @activity.description
      table[3]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[3]['Cost Category Split Total %'].should == "100.0"
      table[3]['Cost Category Split %'].should == "90.0"
      table[3]['Cost Category'].should == @cost_categorization.code.short_display
      table[3]['Purpose Split Total %'].should == '100.0'
      table[3]['Purpose Split %'].should == "20.0"
      table[3]['MTEF Code'].should == "sub_prog_name"
      table[3]['NSP Code'].should == "N/A"
      table[3]['Location Split Total %'].should == '100.0'
      table[3]['Location Split %'].should == "30.0"
      table[3]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[3]['Total Amount ($)'].should == "5.40"
      table[3]['Actual Double Count'].should == @is.double_count?.to_s

      table[4]['Funding Source'].should == @organization.name
      table[4]['Data Source'].should == @organization.name
      table[4]['Implementer'].should == @is.organization.name
      table[4]['Description of Activity'].should == @activity.description
      table[4]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[4]['Cost Category Split Total %'].should == "100.0"
      table[4]['Cost Category Split %'].should == "10.0"
      table[4]['Cost Category'].should == @cost_categorization.code.short_display
      table[4]['Purpose Split Total %'].should == '100.0'
      table[4]['Purpose Split %'].should == "80.0"
      table[4]['MTEF Code'].should == "sub_prog_name"
      table[4]['NSP Code'].should == "N/A"
      table[4]['Location Split Total %'].should == '100.0'
      table[4]['Location Split %'].should == "70.0"
      table[4]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[4]['Total Amount ($)'].should == "5.60"
      table[4]['Actual Double Count'].should == @is.double_count?.to_s

      table[5]['Funding Source'].should == @organization.name
      table[5]['Data Source'].should == @organization.name
      table[5]['Implementer'].should == @is.organization.name
      table[5]['Description of Activity'].should == @activity.description
      table[5]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[5]['Cost Category Split Total %'].should == "100.0"
      table[5]['Cost Category Split %'].should == "10.0"
      table[5]['Cost Category'].should == @cost_categorization.code.short_display
      table[5]['Purpose Split Total %'].should == '100.0'
      table[5]['Purpose Split %'].should == "80.0"
      table[5]['MTEF Code'].should == "sub_prog_name"
      table[5]['NSP Code'].should == "N/A"
      table[5]['Location Split Total %'].should == '100.0'
      table[5]['Location Split %'].should == "30.0"
      table[5]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[5]['Total Amount ($)'].should == "2.40"
      table[5]['Actual Double Count'].should == @is.double_count?.to_s

      table[6]['Funding Source'].should == @organization.name
      table[6]['Data Source'].should == @organization.name
      table[6]['Implementer'].should == @is.organization.name
      table[6]['Description of Activity'].should == @activity.description
      table[6]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[6]['Cost Category Split Total %'].should == "100.0"
      table[6]['Cost Category Split %'].should == "10.0"
      table[6]['Cost Category'].should == @cost_categorization.code.short_display
      table[6]['Purpose Split Total %'].should == '100.0'
      table[6]['Purpose Split %'].should == "20.0"
      table[6]['MTEF Code'].should == "sub_prog_name"
      table[6]['NSP Code'].should == "N/A"
      table[6]['Location Split Total %'].should == '100.0'
      table[6]['Location Split %'].should == "70.0"
      table[6]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[6]['Total Amount ($)'].should == "1.40"
      table[6]['Actual Double Count'].should == @is.double_count?.to_s

      table[7]['Funding Source'].should == @organization.name
      table[7]['Data Source'].should == @organization.name
      table[7]['Implementer'].should == @is.organization.name
      table[7]['Description of Activity'].should == @activity.description
      table[7]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[7]['Cost Category Split Total %'].should == "100.0"
      table[7]['Cost Category Split %'].should == "10.0"
      table[7]['Cost Category'].should == @cost_categorization.code.short_display
      table[7]['Purpose Split Total %'].should == '100.0'
      table[7]['Purpose Split %'].should == "20.0"
      table[7]['MTEF Code'].should == "sub_prog_name"
      table[7]['NSP Code'].should == "N/A"
      table[7]['Location Split Total %'].should == '100.0'
      table[7]['Location Split %'].should == "30.0"
      table[7]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[7]['Total Amount ($)'].should == "0.60"
      table[7]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should adjust the total amounts as per codings (2 of each budget splits and 2 funders)" do
      #total amount is 100 because the amount of the activity is 100 despite being funded 150
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 90, :activity => @activity, :code => @code1
      @cost_categorization1 = Factory :coding_budget_cost_categorization,
        :percentage => 10, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 80,
        :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 20,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 70, :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 30, :activity => @activity, :code => @code1
      @funder2 = Factory :organization, :name => "zz_funder2"
      @project.in_flows << [Factory.build :funding_flow, :from => @funder2,
        :budget => 50]

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "66.67"
      table[0]['Cost Category Split %'].should == "90.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '66.67'
      table[0]['Purpose Split %'].should == "80.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '66.67'
      table[0]['Location Split %'].should == "70.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "33.60"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "66.67"
      table[1]['Cost Category Split %'].should == "90.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '66.67'
      table[1]['Purpose Split %'].should == "80.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '66.67'
      table[1]['Location Split %'].should == "30.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "14.40"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s

      table[2]['Funding Source'].should == @organization.name
      table[2]['Data Source'].should == @organization.name
      table[2]['Implementer'].should == @is.organization.name
      table[2]['Description of Activity'].should == @activity.description
      table[2]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[2]['Cost Category Split Total %'].should == "66.67"
      table[2]['Cost Category Split %'].should == "90.0"
      table[2]['Cost Category'].should == @cost_categorization.code.short_display
      table[2]['Purpose Split Total %'].should == '66.67'
      table[2]['Purpose Split %'].should == "20.0"
      table[2]['MTEF Code'].should == "sub_prog_name"
      table[2]['NSP Code'].should == "N/A"
      table[2]['Location Split Total %'].should == '66.67'
      table[2]['Location Split %'].should == "70.0"
      table[2]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[2]['Total Amount ($)'].should == "8.40"
      table[2]['Actual Double Count'].should == @is.double_count?.to_s

      table[3]['Funding Source'].should == @organization.name
      table[3]['Data Source'].should == @organization.name
      table[3]['Implementer'].should == @is.organization.name
      table[3]['Description of Activity'].should == @activity.description
      table[3]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[3]['Cost Category Split Total %'].should == "66.67"
      table[3]['Cost Category Split %'].should == "90.0"
      table[3]['Cost Category'].should == @cost_categorization.code.short_display
      table[3]['Purpose Split Total %'].should == '66.67'
      table[3]['Purpose Split %'].should == "20.0"
      table[3]['MTEF Code'].should == "sub_prog_name"
      table[3]['NSP Code'].should == "N/A"
      table[3]['Location Split Total %'].should == '66.67'
      table[3]['Location Split %'].should == "30.0"
      table[3]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[3]['Total Amount ($)'].should == "3.60"
      table[3]['Actual Double Count'].should == @is.double_count?.to_s

      table[4]['Funding Source'].should == @organization.name
      table[4]['Data Source'].should == @organization.name
      table[4]['Implementer'].should == @is.organization.name
      table[4]['Description of Activity'].should == @activity.description
      table[4]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[4]['Cost Category Split Total %'].should == "66.67"
      table[4]['Cost Category Split %'].should == "10.0"
      table[4]['Cost Category'].should == @cost_categorization.code.short_display
      table[4]['Purpose Split Total %'].should == '66.67'
      table[4]['Purpose Split %'].should == "80.0"
      table[4]['MTEF Code'].should == "sub_prog_name"
      table[4]['NSP Code'].should == "N/A"
      table[4]['Location Split Total %'].should == '66.67'
      table[4]['Location Split %'].should == "70.0"
      table[4]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[4]['Total Amount ($)'].should == "3.73"
      table[4]['Actual Double Count'].should == @is.double_count?.to_s

      table[5]['Funding Source'].should == @organization.name
      table[5]['Data Source'].should == @organization.name
      table[5]['Implementer'].should == @is.organization.name
      table[5]['Description of Activity'].should == @activity.description
      table[5]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[5]['Cost Category Split Total %'].should == "66.67"
      table[5]['Cost Category Split %'].should == "10.0"
      table[5]['Cost Category'].should == @cost_categorization.code.short_display
      table[5]['Purpose Split Total %'].should == '66.67'
      table[5]['Purpose Split %'].should == "80.0"
      table[5]['MTEF Code'].should == "sub_prog_name"
      table[5]['NSP Code'].should == "N/A"
      table[5]['Location Split Total %'].should == '66.67'
      table[5]['Location Split %'].should == "30.0"
      table[5]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[5]['Total Amount ($)'].should == "1.60"
      table[5]['Actual Double Count'].should == @is.double_count?.to_s

      table[6]['Funding Source'].should == @organization.name
      table[6]['Data Source'].should == @organization.name
      table[6]['Implementer'].should == @is.organization.name
      table[6]['Description of Activity'].should == @activity.description
      table[6]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[6]['Cost Category Split Total %'].should == "66.67"
      table[6]['Cost Category Split %'].should == "10.0"
      table[6]['Cost Category'].should == @cost_categorization.code.short_display
      table[6]['Purpose Split Total %'].should == '66.67'
      table[6]['Purpose Split %'].should == "20.0"
      table[6]['MTEF Code'].should == "sub_prog_name"
      table[6]['NSP Code'].should == "N/A"
      table[6]['Location Split Total %'].should == '66.67'
      table[6]['Location Split %'].should == "70.0"
      table[6]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[6]['Total Amount ($)'].should == "0.93"
      table[6]['Actual Double Count'].should == @is.double_count?.to_s

      table[7]['Funding Source'].should == @organization.name
      table[7]['Data Source'].should == @organization.name
      table[7]['Implementer'].should == @is.organization.name
      table[7]['Description of Activity'].should == @activity.description
      table[7]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[7]['Cost Category Split Total %'].should == "66.67"
      table[7]['Cost Category Split %'].should == "10.0"
      table[7]['Cost Category'].should == @cost_categorization.code.short_display
      table[7]['Purpose Split Total %'].should == '66.67'
      table[7]['Purpose Split %'].should == "20.0"
      table[7]['MTEF Code'].should == "sub_prog_name"
      table[7]['NSP Code'].should == "N/A"
      table[7]['Location Split Total %'].should == '66.67'
      table[7]['Location Split %'].should == "30.0"
      table[7]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[7]['Total Amount ($)'].should == "0.40"
      table[7]['Actual Double Count'].should == @is.double_count?.to_s

      table[8]['Funding Source'].should == @funder2.name
      table[8]['Data Source'].should == @organization.name
      table[8]['Implementer'].should == @is.organization.name
      table[8]['Description of Activity'].should == @activity.description
      table[8]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[8]['Cost Category Split Total %'].should == "33.33"
      table[8]['Cost Category Split %'].should == "90.0"
      table[8]['Cost Category'].should == @cost_categorization.code.short_display
      table[8]['Purpose Split Total %'].should == '33.33'
      table[8]['Purpose Split %'].should == "80.0"
      table[8]['MTEF Code'].should == "sub_prog_name"
      table[8]['NSP Code'].should == "N/A"
      table[8]['Location Split Total %'].should == '33.33'
      table[8]['Location Split %'].should == "70.0"
      table[8]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[8]['Total Amount ($)'].should == "16.80"
      table[8]['Actual Double Count'].should == @is.double_count?.to_s

      table[9]['Funding Source'].should == @funder2.name
      table[9]['Data Source'].should == @organization.name
      table[9]['Implementer'].should == @is.organization.name
      table[9]['Description of Activity'].should == @activity.description
      table[9]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[9]['Cost Category Split Total %'].should == "33.33"
      table[9]['Cost Category Split %'].should == "90.0"
      table[9]['Cost Category'].should == @cost_categorization.code.short_display
      table[9]['Purpose Split Total %'].should == '33.33'
      table[9]['Purpose Split %'].should == "80.0"
      table[9]['MTEF Code'].should == "sub_prog_name"
      table[9]['NSP Code'].should == "N/A"
      table[9]['Location Split Total %'].should == '33.33'
      table[9]['Location Split %'].should == "30.0"
      table[9]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[9]['Total Amount ($)'].should == "7.20"
      table[9]['Actual Double Count'].should == @is.double_count?.to_s

      table[10]['Funding Source'].should == @funder2.name
      table[10]['Data Source'].should == @organization.name
      table[10]['Implementer'].should == @is.organization.name
      table[10]['Description of Activity'].should == @activity.description
      table[10]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[10]['Cost Category Split Total %'].should == "33.33"
      table[10]['Cost Category Split %'].should == "90.0"
      table[10]['Cost Category'].should == @cost_categorization.code.short_display
      table[10]['Purpose Split Total %'].should == '33.33'
      table[10]['Purpose Split %'].should == "20.0"
      table[10]['MTEF Code'].should == "sub_prog_name"
      table[10]['NSP Code'].should == "N/A"
      table[10]['Location Split Total %'].should == '33.33'
      table[10]['Location Split %'].should == "70.0"
      table[10]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[10]['Total Amount ($)'].should == "4.20"
      table[10]['Actual Double Count'].should == @is.double_count?.to_s

      table[11]['Funding Source'].should == @funder2.name
      table[11]['Data Source'].should == @organization.name
      table[11]['Implementer'].should == @is.organization.name
      table[11]['Description of Activity'].should == @activity.description
      table[11]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[11]['Cost Category Split Total %'].should == "33.33"
      table[11]['Cost Category Split %'].should == "90.0"
      table[11]['Cost Category'].should == @cost_categorization.code.short_display
      table[11]['Purpose Split Total %'].should == '33.33'
      table[11]['Purpose Split %'].should == "20.0"
      table[11]['MTEF Code'].should == "sub_prog_name"
      table[11]['NSP Code'].should == "N/A"
      table[11]['Location Split Total %'].should == '33.33'
      table[11]['Location Split %'].should == "30.0"
      table[11]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[11]['Total Amount ($)'].should == "1.80"
      table[11]['Actual Double Count'].should == @is.double_count?.to_s

      table[12]['Funding Source'].should == @funder2.name
      table[12]['Data Source'].should == @organization.name
      table[12]['Implementer'].should == @is.organization.name
      table[12]['Description of Activity'].should == @activity.description
      table[12]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[12]['Cost Category Split Total %'].should == "33.33"
      table[12]['Cost Category Split %'].should == "10.0"
      table[12]['Cost Category'].should == @cost_categorization.code.short_display
      table[12]['Purpose Split Total %'].should == '33.33'
      table[12]['Purpose Split %'].should == "80.0"
      table[12]['MTEF Code'].should == "sub_prog_name"
      table[12]['NSP Code'].should == "N/A"
      table[12]['Location Split Total %'].should == '33.33'
      table[12]['Location Split %'].should == "70.0"
      table[12]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[12]['Total Amount ($)'].should == "1.87"
      table[12]['Actual Double Count'].should == @is.double_count?.to_s

      table[13]['Funding Source'].should == @funder2.name
      table[13]['Data Source'].should == @organization.name
      table[13]['Implementer'].should == @is.organization.name
      table[13]['Description of Activity'].should == @activity.description
      table[13]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[13]['Cost Category Split Total %'].should == "33.33"
      table[13]['Cost Category Split %'].should == "10.0"
      table[13]['Cost Category'].should == @cost_categorization.code.short_display
      table[13]['Purpose Split Total %'].should == '33.33'
      table[13]['Purpose Split %'].should == "80.0"
      table[13]['MTEF Code'].should == "sub_prog_name"
      table[13]['NSP Code'].should == "N/A"
      table[13]['Location Split Total %'].should == '33.33'
      table[13]['Location Split %'].should == "30.0"
      table[13]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[13]['Total Amount ($)'].should == "0.80"
      table[13]['Actual Double Count'].should == @is.double_count?.to_s

      table[14]['Funding Source'].should == @funder2.name
      table[14]['Data Source'].should == @organization.name
      table[14]['Implementer'].should == @is.organization.name
      table[14]['Description of Activity'].should == @activity.description
      table[14]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[14]['Cost Category Split Total %'].should == "33.33"
      table[14]['Cost Category Split %'].should == "10.0"
      table[14]['Cost Category'].should == @cost_categorization.code.short_display
      table[14]['Purpose Split Total %'].should == '33.33'
      table[14]['Purpose Split %'].should == "20.0"
      table[14]['MTEF Code'].should == "sub_prog_name"
      table[14]['NSP Code'].should == "N/A"
      table[14]['Location Split Total %'].should == '33.33'
      table[14]['Location Split %'].should == "70.0"
      table[14]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[14]['Total Amount ($)'].should == "0.47"
      table[14]['Actual Double Count'].should == @is.double_count?.to_s

      table[15]['Funding Source'].should == @funder2.name
      table[15]['Data Source'].should == @organization.name
      table[15]['Implementer'].should == @is.organization.name
      table[15]['Description of Activity'].should == @activity.description
      table[15]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[15]['Cost Category Split Total %'].should == "33.33"
      table[15]['Cost Category Split %'].should == "10.0"
      table[15]['Cost Category'].should == @cost_categorization.code.short_display
      table[15]['Purpose Split Total %'].should == '33.33'
      table[15]['Purpose Split %'].should == "20.0"
      table[15]['MTEF Code'].should == "sub_prog_name"
      table[15]['NSP Code'].should == "N/A"
      table[15]['Location Split Total %'].should == '33.33'
      table[15]['Location Split %'].should == "30.0"
      table[15]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[15]['Total Amount ($)'].should == "0.20"
      table[15]['Actual Double Count'].should == @is.double_count?.to_s
    end
  end

  context "incomplete codings" do
    before :each do
      basic_setup_response
      @response.state = 'accepted'
      @response.save
      in_flows       = [Factory.build :funding_flow, :from => @organization,
        :budget => 100]
      @project      = Factory :project, :data_response => @response,
        :name => 'project',
        :in_flows => in_flows
      @root_code = Factory :code
      @code1          = Factory :code, :official_name => "root"
      @activity      = Factory :activity, :project => @project,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @activity,
        :organization => @organization, :budget => 100
      @mtef = Factory :mtef_code, :short_display => "sub_prog_name"

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @code1.move_to_child_of(@mtef)
      @activity.reload;@activity.save
    end

    it "cost categorization - should replace incomplete codings with 'not coded' (should not affect calculated amounts)" do
      #total amount is 100 because the amount of the activity is 100 despite being funded 150
      @budget_purpose = Factory :budget_purpose, :percentage => 80,
        :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 20,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 70, :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 30, :activity => @activity, :code => @code1
      @funder2 = Factory :organization, :name => "zzfunder2"
      @project.in_flows << [Factory.build :funding_flow, :from => @funder2,
        :budget => 50]

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "N/A"
      table[0]['Cost Category Split %'].should == "N/A"
      table[0]['Cost Category'].should == 'N/A'
      table[0]['Purpose Split Total %'].should == '66.67'
      table[0]['Purpose Split %'].should == "80.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '66.67'
      table[0]['Location Split %'].should == "70.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "37.33"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == 'N/A'
      table[1]['Cost Category Split %'].should == 'N/A'
      table[1]['Cost Category'].should == 'N/A'
      table[1]['Purpose Split Total %'].should == '66.67'
      table[1]['Purpose Split %'].should == "80.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '66.67'
      table[1]['Location Split %'].should == "30.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "16.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s

      table[2]['Funding Source'].should == @organization.name
      table[2]['Data Source'].should == @organization.name
      table[2]['Implementer'].should == @is.organization.name
      table[2]['Description of Activity'].should == @activity.description
      table[2]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[2]['Cost Category Split Total %'].should == 'N/A'
      table[2]['Cost Category Split %'].should == 'N/A'
      table[2]['Cost Category'].should == 'N/A'
      table[2]['Purpose Split Total %'].should == '66.67'
      table[2]['Purpose Split %'].should == "20.0"
      table[2]['MTEF Code'].should == "sub_prog_name"
      table[2]['NSP Code'].should == "N/A"
      table[2]['Location Split Total %'].should == '66.67'
      table[2]['Location Split %'].should == "70.0"
      table[2]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[2]['Total Amount ($)'].should == "9.33"
      table[2]['Actual Double Count'].should == @is.double_count?.to_s

      table[3]['Funding Source'].should == @organization.name
      table[3]['Data Source'].should == @organization.name
      table[3]['Implementer'].should == @is.organization.name
      table[3]['Description of Activity'].should == @activity.description
      table[3]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[3]['Cost Category Split Total %'].should == 'N/A'
      table[3]['Cost Category Split %'].should == 'N/A'
      table[3]['Cost Category'].should == 'N/A'
      table[3]['Purpose Split Total %'].should == '66.67'
      table[3]['Purpose Split %'].should == "20.0"
      table[3]['MTEF Code'].should == "sub_prog_name"
      table[3]['NSP Code'].should == "N/A"
      table[3]['Location Split Total %'].should == '66.67'
      table[3]['Location Split %'].should == "30.0"
      table[3]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[3]['Total Amount ($)'].should == "4.00"
      table[3]['Actual Double Count'].should == @is.double_count?.to_s

      table[4]['Funding Source'].should == @funder2.name
      table[4]['Data Source'].should == @organization.name
      table[4]['Implementer'].should == @is.organization.name
      table[4]['Description of Activity'].should == @activity.description
      table[4]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[4]['Cost Category Split Total %'].should == 'N/A'
      table[4]['Cost Category Split %'].should == 'N/A'
      table[4]['Cost Category'].should == 'N/A'
      table[4]['Purpose Split Total %'].should == '33.33'
      table[4]['Purpose Split %'].should == "80.0"
      table[4]['MTEF Code'].should == "sub_prog_name"
      table[4]['NSP Code'].should == "N/A"
      table[4]['Location Split Total %'].should == '33.33'
      table[4]['Location Split %'].should == "70.0"
      table[4]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[4]['Total Amount ($)'].should == "18.67"
      table[4]['Actual Double Count'].should == @is.double_count?.to_s

      table[5]['Funding Source'].should == @funder2.name
      table[5]['Data Source'].should == @organization.name
      table[5]['Implementer'].should == @is.organization.name
      table[5]['Description of Activity'].should == @activity.description
      table[5]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[5]['Cost Category Split Total %'].should == 'N/A'
      table[5]['Cost Category Split %'].should == 'N/A'
      table[5]['Cost Category'].should == 'N/A'
      table[5]['Purpose Split Total %'].should == '33.33'
      table[5]['Purpose Split %'].should == "80.0"
      table[5]['MTEF Code'].should == "sub_prog_name"
      table[5]['NSP Code'].should == "N/A"
      table[5]['Location Split Total %'].should == '33.33'
      table[5]['Location Split %'].should == "30.0"
      table[5]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[5]['Total Amount ($)'].should == "8.00"
      table[5]['Actual Double Count'].should == @is.double_count?.to_s

      table[6]['Funding Source'].should == @funder2.name
      table[6]['Data Source'].should == @organization.name
      table[6]['Implementer'].should == @is.organization.name
      table[6]['Description of Activity'].should == @activity.description
      table[6]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[6]['Cost Category Split Total %'].should == 'N/A'
      table[6]['Cost Category Split %'].should == 'N/A'
      table[6]['Cost Category'].should == 'N/A'
      table[6]['Purpose Split Total %'].should == '33.33'
      table[6]['Purpose Split %'].should == "20.0"
      table[6]['MTEF Code'].should == "sub_prog_name"
      table[6]['NSP Code'].should == "N/A"
      table[6]['Location Split Total %'].should == '33.33'
      table[6]['Location Split %'].should == "70.0"
      table[6]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[6]['Total Amount ($)'].should == "4.67"
      table[6]['Actual Double Count'].should == @is.double_count?.to_s

      table[7]['Funding Source'].should == @funder2.name
      table[7]['Data Source'].should == @organization.name
      table[7]['Implementer'].should == @is.organization.name
      table[7]['Description of Activity'].should == @activity.description
      table[7]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[7]['Cost Category Split Total %'].should == 'N/A'
      table[7]['Cost Category Split %'].should == 'N/A'
      table[7]['Cost Category'].should == 'N/A'
      table[7]['Purpose Split Total %'].should == '33.33'
      table[7]['Purpose Split %'].should == "20.0"
      table[7]['MTEF Code'].should == "sub_prog_name"
      table[7]['NSP Code'].should == "N/A"
      table[7]['Location Split Total %'].should == '33.33'
      table[7]['Location Split %'].should == "30.0"
      table[7]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[7]['Total Amount ($)'].should == "2.00"
      table[7]['Actual Double Count'].should == @is.double_count?.to_s

      @activity.coding_budget_cost_categorization.size.should == 0
    end

    it "budget purpose - should replace incomplete codings with 'not coded' (should not affect calculated amounts)" do
      #total amount is 100 because the amount of the activity is 100 despite being funded 150
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == '100.0'
      table[0]['Cost Category Split %'].should == '100.0'
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == 'N/A'
      table[0]['Purpose Split %'].should == 'N/A'
      table[0]['MTEF Code'].should == 'N/A'
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == '100.0'
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "100.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      @activity.coding_budget.size.should == 0
      @activity.coding_budget_cost_categorization.size.should == 1
      @activity.coding_budget_district.size.should == 1
    end

    it "budget district - should replace incomplete codings with 'not coded' (should not affect calculated amounts)" do
      #total amount is 100 because the amount of the activity is 100 despite being funded 150
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == '100.0'
      table[0]['Cost Category Split %'].should == '100.0'
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == '100.0'
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == 'N/A'
      table[0]['Location Split %'].should == 'N/A'
      table[0]['Name of District'].should == 'N/A'
      table[0]['Total Amount ($)'].should == "100.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      @activity.coding_budget.size.should == 1
      @activity.coding_budget_cost_categorization.size.should == 1
      @activity.coding_budget_district.size.should == 0
    end
  end

  context "other costs without a project" do
    before :each do
      basic_setup_response
      @response.state = 'accepted'
      @response.save
      @root_code = Factory :code
      @code1          = Factory :code, :official_name => "root"
      @activity      = Factory :other_cost,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @activity,
        :organization => @organization, :budget => 100
      @mtef = Factory :mtef_code, :short_display => "sub_prog_name"

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @code1.move_to_child_of(@mtef)
      @activity.reload;@activity.save
    end

    it "SHOULD NOT ADD/REMOVE A PROJECT" do
      table = run_report
      Project.all.count.should == 0
      @activity.project.should be_nil
    end

    it "should adjust the total amounts as per codings (2 of each budget splits and 2 funders)" do
      #total amount is 100 because the amount of the activity is 100 despite being funded 150
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 90, :activity => @activity, :code => @code1
      @cost_categorization1 = Factory :coding_budget_cost_categorization,
        :percentage => 10, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 80,
        :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 20,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 70, :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 30, :activity => @activity, :code => @code1

      table = run_report
      table[0]['Funding Source'].should == "N/A"
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Project'].should == 'N/A'
      table[0]['Description of Project'].should == 'N/A'
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "90.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "80.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "N/A"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "70.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "50.40"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == 'N/A'
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "90.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "80.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "30.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "21.60"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s

      table[2]['Funding Source'].should == 'N/A'
      table[2]['Data Source'].should == @organization.name
      table[2]['Implementer'].should == @is.organization.name
      table[2]['Description of Activity'].should == @activity.description
      table[2]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[2]['Cost Category Split Total %'].should == "100.0"
      table[2]['Cost Category Split %'].should == "90.0"
      table[2]['Cost Category'].should == @cost_categorization.code.short_display
      table[2]['Purpose Split Total %'].should == '100.0'
      table[2]['Purpose Split %'].should == "20.0"
      table[2]['MTEF Code'].should == "sub_prog_name"
      table[2]['NSP Code'].should == "N/A"
      table[2]['Location Split Total %'].should == '100.0'
      table[2]['Location Split %'].should == "70.0"
      table[2]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[2]['Total Amount ($)'].should == "12.60"
      table[2]['Actual Double Count'].should == @is.double_count?.to_s

      table[3]['Funding Source'].should == 'N/A'
      table[3]['Data Source'].should == @organization.name
      table[3]['Implementer'].should == @is.organization.name
      table[3]['Description of Activity'].should == @activity.description
      table[3]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[3]['Cost Category Split Total %'].should == "100.0"
      table[3]['Cost Category Split %'].should == "90.0"
      table[3]['Cost Category'].should == @cost_categorization.code.short_display
      table[3]['Purpose Split Total %'].should == '100.0'
      table[3]['Purpose Split %'].should == "20.0"
      table[3]['MTEF Code'].should == "sub_prog_name"
      table[3]['NSP Code'].should == "N/A"
      table[3]['Location Split Total %'].should == '100.0'
      table[3]['Location Split %'].should == "30.0"
      table[3]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[3]['Total Amount ($)'].should == "5.40"
      table[3]['Actual Double Count'].should == @is.double_count?.to_s

      table[4]['Funding Source'].should == 'N/A'
      table[4]['Data Source'].should == @organization.name
      table[4]['Implementer'].should == @is.organization.name
      table[4]['Description of Activity'].should == @activity.description
      table[4]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[4]['Cost Category Split Total %'].should == "100.0"
      table[4]['Cost Category Split %'].should == "10.0"
      table[4]['Cost Category'].should == @cost_categorization.code.short_display
      table[4]['Purpose Split Total %'].should == '100.0'
      table[4]['Purpose Split %'].should == "80.0"
      table[4]['MTEF Code'].should == "sub_prog_name"
      table[4]['NSP Code'].should == "N/A"
      table[4]['Location Split Total %'].should == '100.0'
      table[4]['Location Split %'].should == "70.0"
      table[4]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[4]['Total Amount ($)'].should == "5.60"
      table[4]['Actual Double Count'].should == @is.double_count?.to_s

      table[5]['Funding Source'].should == 'N/A'
      table[5]['Data Source'].should == @organization.name
      table[5]['Implementer'].should == @is.organization.name
      table[5]['Description of Activity'].should == @activity.description
      table[5]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[5]['Cost Category Split Total %'].should == "100.0"
      table[5]['Cost Category Split %'].should == "10.0"
      table[5]['Cost Category'].should == @cost_categorization.code.short_display
      table[5]['Purpose Split Total %'].should == '100.0'
      table[5]['Purpose Split %'].should == "80.0"
      table[5]['MTEF Code'].should == "sub_prog_name"
      table[5]['NSP Code'].should == "N/A"
      table[5]['Location Split Total %'].should == '100.0'
      table[5]['Location Split %'].should == "30.0"
      table[5]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[5]['Total Amount ($)'].should == "2.40"
      table[5]['Actual Double Count'].should == @is.double_count?.to_s

      table[6]['Funding Source'].should == 'N/A'
      table[6]['Data Source'].should == @organization.name
      table[6]['Implementer'].should == @is.organization.name
      table[6]['Description of Activity'].should == @activity.description
      table[6]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[6]['Cost Category Split Total %'].should == "100.0"
      table[6]['Cost Category Split %'].should == "10.0"
      table[6]['Cost Category'].should == @cost_categorization.code.short_display
      table[6]['Purpose Split Total %'].should == '100.0'
      table[6]['Purpose Split %'].should == "20.0"
      table[6]['MTEF Code'].should == "sub_prog_name"
      table[6]['NSP Code'].should == "N/A"
      table[6]['Location Split Total %'].should == '100.0'
      table[6]['Location Split %'].should == "70.0"
      table[6]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[6]['Total Amount ($)'].should == "1.40"
      table[6]['Actual Double Count'].should == @is.double_count?.to_s

      table[7]['Funding Source'].should == 'N/A'
      table[7]['Data Source'].should == @organization.name
      table[7]['Implementer'].should == @is.organization.name
      table[7]['Description of Activity'].should == @activity.description
      table[7]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[7]['Cost Category Split Total %'].should == "100.0"
      table[7]['Cost Category Split %'].should == "10.0"
      table[7]['Cost Category'].should == @cost_categorization.code.short_display
      table[7]['Purpose Split Total %'].should == '100.0'
      table[7]['Purpose Split %'].should == "20.0"
      table[7]['MTEF Code'].should == "sub_prog_name"
      table[7]['NSP Code'].should == "N/A"
      table[7]['Location Split Total %'].should == '100.0'
      table[7]['Location Split %'].should == "30.0"
      table[7]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[7]['Total Amount ($)'].should == "0.60"
      table[7]['Actual Double Count'].should == @is.double_count?.to_s

      sum = 0
      (0..7).each { |i| sum += table[i]['Total Amount ($)'].to_f}
      sum.should == 100.0
    end
  end

  context "currency conversion" do
    before :each do
      basic_setup_response
      @currency = Factory(:currency, :conversion => 'RWF_TO_USD', :rate => 0.5)
      @organization.currency = 'RWF'
      @organization.save!
      @response.state = 'accepted'
      @response.save
      in_flows       = [Factory.build :funding_flow, :from => @organization,
        :budget => 100]
      @project      = Factory :project, :data_response => @response,
        :name => 'project',
        :in_flows => in_flows
      @root_code = Factory :code
      @code1          = Factory :code, :official_name => "root"
      @mtef = Factory :mtef_code, :short_display => "sub_prog_name"
      @nsp = Factory :nsp_code, :short_display => "Nsp_code"

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @nsp.move_to_child_of(@mtef)
      @code1.move_to_child_of(@nsp)
    end

    it "should convert amounts to USD" do
      @activity      = Factory :activity, :project => @project,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @activity,
        :organization => @organization, :budget => 100
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1
      @activity.reload;@activity.save

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "50.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should correctly create the currency for a fake project for an activity/othercost" do
      @other_cost      = Factory :other_cost,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @other_cost,
        :organization => @organization, :budget => 100
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @other_cost, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @other_cost, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @other_cost, :code => @code1
      @other_cost.reload;@other_cost.save
      table = run_report
      table[0]['Funding Source'].should == "N/A"
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @other_cost.description
      table[0]['Targets'].should == @other_cost.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @other_cost.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "50.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

    end
  end

  context "Incomplete classifications" do
    before :each do
      basic_setup_response
      @response.state = 'accepted'
      @response.save
      in_flows       = [Factory.build :funding_flow, :from => @organization,
        :budget => 100]
      @project      = Factory :project, :data_response => @response,
        :name => 'project',
        :in_flows => in_flows
      @activity      = Factory :activity, :project => @project,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @activity,
        :organization => @organization, :budget => 100
      @root_code = Factory :code
      @mtef = Factory :mtef_code, :short_display => "sub_prog_name"
      @code1          = Factory :code, :official_name => "root"
      @nsp = Factory :nsp_code, :short_display => "Nsp_code"

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @nsp.move_to_child_of(@mtef)
      @code1.move_to_child_of(@nsp)
      @activity.reload;@activity.save
    end

    it "should create a purposes row with the outstanding amount (should make 2 rows)" do
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 90,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "90.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "90.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "100.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "10.0"
      table[1]['MTEF Code'].should == "N/A"
      table[1]['NSP Code'].should == "N/A"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "100.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "10.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should create a inputs row with the outstanding amount (should make 2 rows)" do
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 80, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "80.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "80.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "20.0"
      table[1]['Cost Category'].should == "Not Classified"
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "100.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "Nsp_code"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "100.0"
      table[1]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[1]['Total Amount ($)'].should == "20.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should create a districts row with the outstanding amount (should make 2 rows)" do
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 85, :activity => @activity, :code => @code1

      table = run_report
      table[0]['Funding Source'].should == @organization.name
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "85.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "85.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s

      table[1]['Funding Source'].should == @organization.name
      table[1]['Data Source'].should == @organization.name
      table[1]['Implementer'].should == @is.organization.name
      table[1]['Description of Activity'].should == @activity.description
      table[1]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[1]['Cost Category Split Total %'].should == "100.0"
      table[1]['Cost Category Split %'].should == "100.0"
      table[1]['Cost Category'].should == @cost_categorization.code.short_display
      table[1]['Purpose Split Total %'].should == '100.0'
      table[1]['Purpose Split %'].should == "100.0"
      table[1]['MTEF Code'].should == "sub_prog_name"
      table[1]['NSP Code'].should == "Nsp_code"
      table[1]['Location Split Total %'].should == '100.0'
      table[1]['Location Split %'].should == "15.0"
      table[1]['Name of District'].should == "Not Classified"
      table[1]['Total Amount ($)'].should == "15.00"
      table[1]['Actual Double Count'].should == @is.double_count?.to_s
    end

    context "within allowed leeway" do
      it "should not create a inputs row with the outstanding amount (should make 1 row)" do
        @cost_categorization = Factory :coding_budget_cost_categorization,
          :percentage => 99.5, :activity => @activity, :code => @code1
        @budget_purpose = Factory :budget_purpose, :percentage => 100,
          :activity => @activity, :code => @code1
        @coding_budget_district = Factory :coding_budget_district,
          :percentage => 100, :activity => @activity, :code => @code1

        table = run_report
        table[0]['Funding Source'].should == @organization.name
        table[0]['Data Source'].should == @organization.name
        table[0]['Implementer'].should == @is.organization.name
        table[0]['Description of Activity'].should == @activity.description
        table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
        table[0]['Cost Category Split Total %'].should == "99.5"
        table[0]['Cost Category Split %'].should == "99.5"
        table[0]['Cost Category'].should == @cost_categorization.code.short_display
        table[0]['Purpose Split Total %'].should == '100.0'
        table[0]['Purpose Split %'].should == "100.0"
        table[0]['MTEF Code'].should == "sub_prog_name"
        table[0]['NSP Code'].should == "Nsp_code"
        table[0]['Location Split Total %'].should == '100.0'
        table[0]['Location Split %'].should == "100.0"
        table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
        table[0]['Total Amount ($)'].should == "99.50"
        table[0]['Actual Double Count'].should == @is.double_count?.to_s

        table[1].should be_nil
      end
    end
  end

  describe "spend_report" do
    def run_spend_report
      report = Reports::DynamicQuery.new(@request, :spend)
      csv = report.csv
      table = []
      FasterCSV.parse(csv, :headers => true) { |row| table << row }
      return table
    end

    context "simple reports" do
      before :each do
        basic_setup_response
        @response.state = 'accepted'
        @response.save
        in_flows       = [Factory.build :funding_flow, :from => @organization,
          :spend => 100]
        @project      = Factory :project, :data_response => @response,
          :name => 'project',
          :in_flows => in_flows
        @root_code = Factory :code
        @code1          = Factory :code, :official_name => "root"
        @activity      = Factory :activity, :project => @project,
          :data_response => @response, :description => "desc"
        @is            = Factory :implementer_split, :activity => @activity,
          :organization => @organization, :spend => 100
        @mtef = Factory :mtef_code, :short_display => "sub_prog_name"
        @nsp = Factory :nsp_code, :short_display => "Nsp_code"
        @cost_categorization = Factory :coding_spend_cost_categorization,
          :percentage => 100, :activity => @activity, :code => @code1
        @spend_purpose = Factory :spend_purpose, :percentage => 100,
          :activity => @activity, :code => @code1
        @coding_spend_district = Factory :coding_spend_district,
          :percentage => 100, :activity => @activity, :code => @code1

        #creating dummy tree
        @mtef.move_to_child_of(@root_code)
        @nsp.move_to_child_of(@mtef)
        @code1.move_to_child_of(@nsp)
        @activity.reload;@activity.save
      end

      it "should return a 1 funder, 1 implementer report" do
        table = run_spend_report
        table[0]['Funding Source'].should == @organization.name
        table[0]['Data Source'].should == @organization.name
        table[0]['Implementer'].should == @is.organization.name
        table[0]['Description of Activity'].should == @activity.description
        table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
        table[0]['Cost Category Split Total %'].should == "100.0"
        table[0]['Cost Category Split %'].should == "100.0"
        table[0]['Cost Category'].should == @cost_categorization.code.short_display
        table[0]['Purpose Split Total %'].should == '100.0'
        table[0]['Purpose Split %'].should == "100.0"
        table[0]['MTEF Code'].should == "sub_prog_name"
        table[0]['NSP Code'].should == "Nsp_code"
        table[0]['Location Split Total %'].should == '100.0'
        table[0]['Location Split %'].should == "100.0"
        table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
        table[0]['Total Amount ($)'].should == "100.00"
        table[0]['Actual Double Count'].should == @is.double_count?.to_s
      end
    end
  end

  context "organization has funders without amounts" do
    before :each do
      basic_setup_response
      @response.state = 'accepted'
      @response.save
      in_flows       = [Factory.build :funding_flow, :from => @organization,
        :budget => 0]
      @project      = Factory :project, :data_response => @response,
        :name => 'project',
        :in_flows => in_flows
      @root_code = Factory :code
      @code1          = Factory :code, :official_name => "root"
      @activity      = Factory :activity, :project => @project,
        :data_response => @response, :description => "desc"
      @is            = Factory :implementer_split, :activity => @activity,
        :organization => @organization, :budget => 100
      @mtef = Factory :mtef_code, :short_display => "sub_prog_name"
      @nsp = Factory :nsp_code, :short_display => "Nsp_code"
      @cost_categorization = Factory :coding_budget_cost_categorization,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = Factory :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @coding_budget_district = Factory :coding_budget_district,
        :percentage => 100, :activity => @activity, :code => @code1

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @nsp.move_to_child_of(@mtef)
      @code1.move_to_child_of(@nsp)
      @activity.reload;@activity.save
    end

    it "should create return no financing agent" do
      table = run_report
      table[0]['Funding Source'].should == "N/A"
      table[0]['Data Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == @activity.targets.map(&:description).join(',')
      table[0]['Cost Category Split Total %'].should == "100.0"
      table[0]['Cost Category Split %'].should == "100.0"
      table[0]['Cost Category'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == '100.0'
      table[0]['Purpose Split %'].should == "100.0"
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == '100.0'
      table[0]['Location Split %'].should == "100.0"
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].should == "100.00"
      table[0]['Actual Double Count'].should == @is.double_count?.to_s
    end

    it "should NOT ADD OR REMOVE INFLOWS!!!" do
      @activity.project.in_flows.size.should == 1 #sanity
      table = run_report
      @activity.project.in_flows.size.should == 1
    end
  end
end
