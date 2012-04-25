require File.dirname(__FILE__) + '/../spec_helper_lite'
$: << File.join(APP_ROOT, "app/models")
require 'app/models/location_split'

describe LocationSplit do
  let(:split) { LocationSplit.new('some loc', 10, 20)}

  it "inits with name, spend and budget" do
    split.name.should == 'some loc'
    split.total_spend.should == 10
    split.total_budget.should == 20
  end

  it "inits without spend/budget" do
    lambda { LocationSplit.new('loc') }.should_not raise_exception
  end

  it "sorts  by name" do
    split1 = LocationSplit.new('aa loc')
    [split, split1].sort.should == [split1, split]
  end

end
