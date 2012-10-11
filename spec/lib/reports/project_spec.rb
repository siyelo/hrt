require 'spec_helper'

describe Reports::Project do
  let(:activity) { mock :activity, name: 'activity', total_spend: 5, total_budget: 10 }
  let(:activity1) { mock :activity, name: 'activity1', total_spend: 10, total_budget: 5 }
  let(:activities) { [activity, activity1] }
  let(:project) { mock :project, activities: activities,
    total_spend: 10, total_budget: 20, name: 'Project1', currency: 'USD' }
  let(:report) { Reports::Project.new(project) }

  it 'returns all activities and other costs for current Project sorted by name' do
    othercost = mock :othercost, name: 'aa_othercost', total_spend: 5, total_budget: 10
    othercost1 = mock :othercost, name: 'zz_othercost', total_spend: 5, total_budget: 10
    othercosts = [othercost, othercost1]
    project.stub_chain(:activities, :sorted).and_return othercosts
    report.collection.should == othercosts
  end

  it "#total_spend" do
    report.total_spend.should == 10
  end

  it "#total_budget" do
    report.total_budget.should == 20
  end

  it "should have a name" do
    report.name.should == 'Project1'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "uses the same colours for budget and spend" do
    project.stub_chain(:activities, :sorted).and_return activities
    JSON.parse(report.budget_colours).should ==
      {"0" => {"color" => "#dc3912"},
       "1" => {"color" => "#3366cc"}}
    JSON.parse(report.expenditure_colours).should ==
      {"0" => {"color" => "#3366cc"},
       "1" => {"color" => "#dc3912"}}
  end

  it "numbers duplicates" do
    activity2 = mock :activity, name: 'activity', total_spend: 6, total_budget: 10
    activities2 = [activity, activity1, activity2]
    project.stub_chain(:activities, :sorted).and_return activities2
    report.collection.map(&:name).should == ["activity", "activity 2", "activity1"]
  end

  it "does not combines activities with the same name" do
    activity2 = mock :activity, name: 'activity', total_spend: 6, total_budget: 10
    activities2 = [activity, activity1, activity2]
    project.stub_chain(:activities, :sorted).and_return activities2
    JSON.parse(report.budget_colours).should ==
      {"0"=>{"color"=>"#ff9900"},
       "1"=>{"color"=>"#dc3912"},
       "2"=>{"color"=>"#3366cc"}}
    JSON.parse(report.expenditure_colours).should ==
      {"0"=>{"color"=>"#3366cc"},
       "1"=>{"color"=>"#dc3912"},
       "2"=>{"color"=>"#ff9900"}}
  end
end
