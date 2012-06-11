require 'spec_helper'

describe Reports::Row do
  let(:split) { Reports::Row.new('some name', 10, 20)}

  it "inits with name, spend and budget" do
    split.name.should == 'some name'
    split.total_spend.should == 10
    split.total_budget.should == 20
  end

  it "inits without spend/budget" do
    lambda { Reports::Row.new('loc') }.should_not raise_exception
  end

  it "sorts by name" do
    split1 = Reports::Row.new('aa loc')
    [split, split1].sort.should == [split1, split]
  end

  it "is equal if name, total_spend and total_budget match" do
    split1 = Reports::Row.new('some name', 10, 20)
    split.should == split1
  end

  it "is not equal if name, total_spend and total_budget dont match" do
    split1 = Reports::Row.new('aa loc', 10, 20)
    (split == split1).should be_false
  end
end
