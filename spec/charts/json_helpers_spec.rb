require 'spec_helper'

describe Charts::JsonHelpers do
  describe "#build_pie_values_json" do
    it "returns a formatted empty JSON hash if no values are passed to it" do
      records = nil
      json_string = "{\"names\":{},\"values\":[]}"
      Charts::JsonHelpers.should_receive(:build_empty_pie_values_json).once.
        and_return(json_string)
      Charts::JsonHelpers.build_pie_values_json(records).should == json_string
    end

    it "returns a formatted JSON from a 2d array" do
      records = [["SOMETHING", 60], ["SOMETHINGELSE", 40]]
      pie_values = Charts::JsonHelpers.build_pie_values_json(records)
      result = JSON.parse(pie_values)
      result["values"].should == records
      result["names"]["column1"].should == "Name"
      result["names"]["column2"].should == "Amount"
    end
  end
end
