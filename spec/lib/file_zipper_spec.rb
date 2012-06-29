require File.dirname(__FILE__) + '/../spec_helper'

describe FileZipper do
  it "can unzip a zip file" do
    content = FileZipper.unzip("#{Rails.root}/spec/fixtures/activity_overview.zip")
    rows = FileParser.parse(content, 'xls')
    rows.length.should == 2
    rows[0]["Activity"].should == "activity1"
    rows[1]["Activity"].should == "activity2"
  end

  it "can create a temporary zip file" do
    tmp_file_name = "tmpfile.txt"
    tmp_folder = "#{Rails.root}/tmp/"
    File.open(tmp_folder + tmp_file_name, 'w') { |f| f.puts 'test' }
    zip_file_name = nil
    FileZipper.zip(tmp_folder, tmp_file_name) do |filename|
      zip_file_name = filename
      File.exists?(filename).should be_true
    end
    File.exists?(zip_file_name).should be_false
  end
end

