require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/inputs'

describe Charts::Inputs do
  describe Charts::Inputs::Spend do
    it "defaults value method to :total_spend" do
      Charts::Inputs::Spend.value_method.should == :total_spend
    end
  end

  describe Charts::Inputs::Budget do
    it "defaults value method to :total_budget" do
      Charts::Inputs::Budget.value_method.should == :total_budget
    end
  end
end
