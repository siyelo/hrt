require 'spec_helper'

describe ClassifiedAmountCacheUpdater do
  let (:purpose)  { FactoryGirl.create(:purpose, name: 'purpose1') }
  let (:input)    { FactoryGirl.create(:input, name: 'input1') }

  before :each do
    basic_setup_activity
    @activity.stub(:total_spend).and_return(200)
    @activity.stub(:total_budget).and_return(100)
    @split1 = FactoryGirl.create(:purpose_budget_split, activity: @activity,
                                code: purpose, percentage: 10, cached_amount: 0)
    @split2 = FactoryGirl.create(:input_spend_split, activity: @activity,
                                code: input, percentage: 20, cached_amount: 0)
  end

  it "updates a single cached amount" do
    updater = ClassifiedAmountCacheUpdater.new(@activity)
    updater.update(:purpose, :budget)

    @split1.reload; @split2.reload
    @split1.cached_amount.to_f.should == 10
    @split2.cached_amount.to_f.should == 0
  end

  it "updates all cached amounts" do
    updater = ClassifiedAmountCacheUpdater.new(@activity)
    updater.update_all

    @split1.reload; @split2.reload
    @split1.cached_amount.to_f.should == 10
    @split2.cached_amount.to_f.should == 40
  end
end
