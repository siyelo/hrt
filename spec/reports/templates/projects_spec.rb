require File.dirname(__FILE__) + '/../../spec_helper'

describe Reports::Templates::Projects do
  it "returns template" do
    report = Reports::Templates::Projects.new('csv').data
    FileParser.parse(report, 'csv')[0].should == Reports::ProjectsExport::FILE_UPLOAD_COLUMNS
  end
end
