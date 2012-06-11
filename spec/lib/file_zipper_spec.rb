require File.dirname(__FILE__) + '/../spec_helper'

describe FileZipper do
  it "can unzip a zip file" do
    attachment = FileZipper.unzip("#{Rails.root}/spec/fixtures/activity_overview.zip")
    attachment.should == File.open("#{Rails.root}/spec/fixtures/activity_overview.xls").read
  end

  it "can create a temporary zip file" do
    tmp_file_name = "#{Rails.root}/tmp/tmpfile.txt"
    File.open(tmp_file_name, 'w') { |f| f.puts 'test' }
    zip_file_name = nil
    FileZipper.zip(tmp_file_name) do |filename|
      zip_file_name = filename
      File.exists?(filename).should be_true
    end
    File.exists?(zip_file_name).should be_false
  end
end

