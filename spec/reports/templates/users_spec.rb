require File.dirname(__FILE__) + '/../../spec_helper'

describe Reports::Templates::Users do
  it "returns template" do
    report = Reports::Templates::Users.new('csv').data
    FileParser.parse(report, 'csv')[0].should == User::FILE_UPLOAD_COLUMNS
  end
end
