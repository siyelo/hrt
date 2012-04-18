require File.dirname(__FILE__) + '/../spec_helper'

describe DataRequest do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:final_review) }
  end

  describe "Associations" do
    it { should belong_to :organization }
    it { should have_many(:data_responses).dependent(:destroy) }
    it { should have_many(:reports).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of :organization_id }
    it { should validate_presence_of :title }
    it { should allow_value('2010-12-01').for(:due_date) }
    it { should allow_value('2010-12-01').for(:start_date) }
    it { should allow_value('2010-12-01').for(:end_date) }
    it { should_not allow_value('').for(:due_date) }
    it { should_not allow_value('').for(:start_date) }
    it { should_not allow_value('').for(:end_date) }
    it { should_not allow_value('2010-13-01').for(:due_date) }
    it { should_not allow_value('2010-13-01').for(:start_date) }
    it { should_not allow_value('2010-13-01').for(:end_date) }
    it { should_not allow_value('2010-12-41').for(:due_date) }
    it { should_not allow_value('2010-12-41').for(:start_date) }
    it { should_not allow_value('2010-12-41').for(:end_date) }

    it "accepts start date < end date" do
      dr = Factory.build(:data_request,
                         :start_date => DateTime.new(2010, 01, 01),
                         :end_date =>   DateTime.new(2010, 01, 02) )
      dr.should be_valid
    end

    it "does allow the due date to be empty" do
      dr = Factory.build(:data_request,
                         :start_date => DateTime.new(2010, 01, 01),
                         :end_date =>   DateTime.new(2010, 01, 02),
                         :due_date => nil )
    end

    it "does not accept start date > end date" do
      dr = Factory.build(:data_request,
                         :start_date => DateTime.new(2010, 01, 02),
                         :end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end

    it "does not accept start date = end date" do
      dr = Factory.build(:data_request,
                         :start_date => DateTime.new(2010, 01, 01),
                         :end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end
  end

  describe "Callbacks" do
    # after_create :create_data_responses
    it "creates data_responses for each organization after data_request is created" do
      org1 = Factory(:organization)
      org2 = Factory(:organization)
      data_request = Factory.create(:data_request, :organization => org1)
      data_request.data_responses.count.should == 2
      organizations = data_request.data_responses.map(&:organization)

      organizations.should include(org1)
      organizations.should include(org2)
    end

    it "does not create data_responses for Non-Reporting organizations" do
      org = Factory(:organization, :raw_type => 'Non-Reporting')
      Factory(:data_request, :organization => org)

      org.data_responses.should be_empty
    end
  end

  describe "#previous_request" do
    let(:data_request) { Factory(:data_request, :start_date => "2011-01-01",
                                 :end_date => "2012-01-01") }

    it "returns nil when no previous request" do
      data_request.previous_request.should be_nil
    end

    it "returns the previous request" do
      previous_request = Factory(:data_request, :start_date => "2010-01-01",
                                 :end_date => "2011-01-01")

      data_request.previous_request.should == previous_request
    end
  end

  describe "#next_request" do
    let(:data_request) { Factory(:data_request, :start_date => "2011-01-01",
                                 :end_date => "2012-01-01") }

    it "returns nil when no next request" do
      data_request.next_request.should be_nil
    end

    it "returns the next request" do
      next_request = Factory(:data_request, :start_date => "2012-01-01",
                                 :end_date => "2013-01-01")

      data_request.next_request.should == next_request
    end
  end
end
