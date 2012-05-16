require File.dirname(__FILE__) + '/../../spec_helper'

describe Reports::Templates::Codes do
  it "returns template" do
    report = Reports::Templates::Codes.new('csv').data
    FileParser.parse(report, 'csv')[0].should == Code::FILE_UPLOAD_COLUMNS
  end
end
