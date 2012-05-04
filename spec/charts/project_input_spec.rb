require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/project_inputs'

describe Charts::ProjectInputs do
  describe Charts::ProjectInputs::Spend do
    it "defaults value method to :total_spend" do
      Charts::ProjectInputs::Spend.value_method.should == :total_spend
    end
  end

  describe Charts::Inputs::Budget do
    it "defaults value method to :total_budget" do
      Charts::ProjectInputs::Budget.value_method.should == :total_budget
    end
  end
end
