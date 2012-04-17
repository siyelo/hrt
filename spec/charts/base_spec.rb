require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/base'
require 'json'

describe Charts::Base do
  let(:entity){ mock :object, :name => "E1", :amount => 20}
  let(:entity2){ mock :object, :name => "E2", :amount => 10}
  let(:entities) { [entity, entity2] }
  let(:chart) { Charts::Base.new(entities) }

  it "defaults name method to :name" do
    Charts::Base.name_method.should == :name
  end

  it "capitalizes names by default" do
    Charts::Base.name_format.should == :capitalize
  end

  it "defines :amount as value_method for collection though subclasses usually override" do
    Charts::Base.value_method.should == :amount
  end

  it "formats values as floats" do
    Charts::Base.value_format.should == :to_f
  end

  it "builds empty chart from empty collection" do
    Charts::Base.new([]).data.should == {}
  end

  it "builds raw chart from supplied collection" do
    chart.data["E1"].should == 20
    chart.data["E2"].should == 10
  end

  it "formats chart data as google pie json" do
    pie = JSON.parse(chart.google_pie)
    pie["values"].should == [["E1", 20.0], ["E2", 10.0]]
    pie["names"]["column1"].should == "Name"
    pie["names"]["column2"].should == "Amount"
  end

  it "formats chart data as google bar json" do
    bar = JSON.parse(chart.google_bar)
    bar[0][0].should == 'Default Bar Chart Title'
    bar[0][1].should == "E1"
    bar[0][2].should == "E2"
    bar[1][0].should == ''
    bar[1][1].should == 66.67 #20 - bar charts show as %
    bar[1][2].should == 33.33 #10
  end
end
