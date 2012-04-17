require 'spec_helper'

describe Admin::CurrenciesHelper do
  describe "dates" do
    it "formats the dates correctly" do
      date = DateTime.parse('2001-02-13')
      helper.format_date(date).should == "13 Feb 2001"
    end
  end
end
