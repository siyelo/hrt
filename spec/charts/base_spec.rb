require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/base'
require 'json'

describe Charts::Base do
  let(:entity){ mock :object, :name => "E2", :amount => 10}
  let(:entity2){ mock :object, :name => "E1", :amount => 30}
  let(:entity3){ mock :object, :name => "E3", :amount => 20}
  let(:entities) { [entity, entity2, entity3] }
  let(:chart) { Charts::Base.new(entities) }

  it "defaults name method to :name" do
    Charts::Base.name_method.should == :name
  end

  it "capitalizes names by default" do
    Charts::Base.name_format.should == :capitalize
  end

  it "defaults name to 'no name' if its nil" do
    e = mock :object, :name => nil, :amount => 10
    Charts::Base.new([e]).data["No name"].should == 10
  end

  it "defines :amount as value_method for collection though subclasses usually override" do
    Charts::Base.value_method.should == :amount
  end

  it "formats values as floats" do
    Charts::Base.value_format.should == :to_f
  end

  it "doesnt include zero elements" do
    e = mock :object, :name => "E1", :amount => 0
    Charts::Base.new([e]).data.should == {}
  end

  it "builds empty chart from empty collection" do
    Charts::Base.new([]).data.should == {}
  end

  it "builds raw chart from supplied collection" do
    chart.data["E1"].should == 30
    chart.data["E2"].should == 10
    chart.data["E3"].should == 20
  end

  it "formats chart data as google pie json, sorted by value desc" do
    pie = JSON.parse(chart.google_pie)
    pie["values"].should == [["E1", 30.0], ["E3", 20.0], ["E2", 10.0]]
    pie["names"]["column1"].should == "Name"
    pie["names"]["column2"].should == "Amount"
  end

  it "formats chart data as google bar json, sorted by name" do
    bar = JSON.parse(chart.google_bar)
    bar[0][0].should == 'Default Bar Chart Title'
    bar[0][1].should == "E1"
    bar[0][2].should == "E2"
    bar[0][3].should == "E3"
    bar[1][0].should == ''
    bar[1][1].should == 50
    bar[1][2].should == 16.67
    bar[1][3].should == 33.33
  end

  it "#bar_sort defaults to sort by name" do
    data = JSON.parse(chart.google_bar)[0]
    data[0].should == "Default Bar Chart Title"
    data[1].should == "E1"
    data[2].should == "E2"
    data[3].should == "E3"
  end

  it "#pie_sort defaults to sort by values desc" do
    data = JSON.parse(chart.google_pie)["values"]
    data[0].should == ["E1", 30]
    data[1].should == ["E3", 20]
    data[2].should == ["E2", 10]
  end
end
