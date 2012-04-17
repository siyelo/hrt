require File.dirname(__FILE__) + '/../spec_helper'
require 'app/charts/responses'

describe Charts::Responses::State do
  let(:request) { mock :request, :id => 1 }
  let(:responses) { [mock(:row, :state => 'In Progress', :count => 10),
    mock(:row, :state => 'Accepted', :count => 20) ]}

  it "initializes with a request" do
    #DataResponse.stub(:find).and_return responses
    DataResponse.should_receive(:find).once.and_return responses
    chart = Charts::Responses::State.new(request)
    chart.data["In Progress"].should == 10
    chart.data["Accepted"].should == 20
  end
end

