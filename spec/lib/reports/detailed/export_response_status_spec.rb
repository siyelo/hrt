require 'spec_helper'

describe Reports::Detailed::ExportResponseStatus do
  def run_report
    content = Reports::Detailed::ExportResponseStatus.new('xls').data
    FileParser.parse(content, 'xls')
  end

  before :each do
    basic_setup_response
  end

  it "generates the report" do
    table = run_report
    table[0]['Response ID'].should == 1
    table[0]['Response Name'].should == @response.title
    table[0]['Organization Name'].should == @organization.name
    table[0]['State'].should == 'unstarted'
  end
end
