require 'spec_helper'

describe Charts::Responses::State do
  let(:request) { mock :request, id: 1 }
  let(:responses) { [mock(:row, state: 'Started', count: 10),
    mock(:row, state: 'Accepted', count: 20),
    mock(:row, state: 'Unstarted', count: 30) ]}

  before :each do
    DataResponse.should_receive(:find).once.and_return responses
  end
  it "initializes with a request" do
    chart = Charts::Responses::State.new(request)
    chart.data["Started"].should == 10
    chart.data["Accepted"].should == 20
  end

  it "#bar_sort orders bars by states" do
    chart = Charts::Responses::State.new(request)
    chart.bar_sort.should == [['Unstarted', 30], ['Started', 10], ['Accepted', 20]]
  end

  it "sorts bar chart by state" do
    chart = Charts::Responses::State.new([])
    DataResponse::STATES.should_receive(:index).exactly(3).times.and_return 1
    chart.sort_by_state
  end

  it "orders the states in bar JSON" do
    chart = Charts::Responses::State.new(request)
    bar = JSON.parse(chart.google_bar)
    bar[0][0].should == 'Responses'
    bar[0][1].should == "Unstarted"
    bar[0][2].should == "Started"
    bar[0][3].should == "Accepted"
    bar[1][0].should == ''
    bar[1][1].should == 50
    bar[1][2].should == 16.67
    bar[1][3].should == 33.33
  end
end
