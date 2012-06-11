require 'spec_helper_lite'

require File.join(APP_ROOT, 'lib/charts/responses')

describe Charts::Responses::State do
  it "uses state as pie name labels" do
    Charts::Responses::State.name_method.should == :state
  end

  it "uses aggregated count column as pie values" do
    Charts::Responses::State.value_method.should == :count
  end

  it "formats values as integers" do
    Charts::Responses::State.value_format.should == :to_i
  end
end
