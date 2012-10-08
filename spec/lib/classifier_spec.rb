require 'spec_helper'

describe Classifier do
  let(:purpose) { FactoryGirl.create(:purpose, :name => 'purpose1') }

  it "classifies a code only once" do
    basic_setup_activity

    classifier = Classifier.new(activity, code_type, amount_type)
    classifier.update_classifications({ purpose.id => 5, purpose.id => 6 })

    splits = purpose.code_splits.purposes.spend.all
    splits.length.should == 1
    splits.first.percentage.should == 6
  end

end
