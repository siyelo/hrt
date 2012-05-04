require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/project_locations'

describe Charts::ProjectLocations do
  describe Charts::ProjectLocations::Spend do
    it "defaults value method to :total_spend" do
      Charts::ProjectLocations::Spend.value_method.should == :total_spend
    end
  end

  describe Charts::ProjectLocations::Budget do
    it "defaults value method to :total_budget" do
      Charts::ProjectLocations::Budget.value_method.should == :total_budget
    end
  end
end
