require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/locations'

describe Charts::Locations do
  describe Charts::Locations::Spend do
    it "defaults value method to :total_spend" do
      Charts::Locations::Spend.value_method.should == :total_spend
    end
  end

  describe Charts::Locations::Budget do
    it "defaults value method to :total_budget" do
      Charts::Locations::Budget.value_method.should == :total_budget
    end
  end
end
