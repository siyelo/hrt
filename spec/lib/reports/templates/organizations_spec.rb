require 'spec_helper'

describe Reports::Templates::Organizations do
  before :each do
    @organization = FactoryGirl.create(:organization, name: 'blarorg', raw_type: 'NGO', fosaid: "13")
  end

  it "will return just the headers if no organizations are passed" do
    report = Reports::Templates::Organizations.new([], 'csv').data
    FileParser.parse(report, 'csv')[0].should == Organization::FILE_UPLOAD_COLUMNS
  end

  it "will return a list of organizations if there are present" do
    report = Reports::Templates::Organizations.new([@organization], 'csv').data
    FileParser.parse(report, 'csv')[0].should == Organization::FILE_UPLOAD_COLUMNS
    FileParser.parse(report, 'csv')[1].should == ['blarorg', 'NGO' , '13' , 'USD']
  end
end
