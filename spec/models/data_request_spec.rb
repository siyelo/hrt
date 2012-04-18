require File.dirname(__FILE__) + '/../spec_helper'

describe DataRequest do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:start_date) }
  end

  describe "Associations" do
    it { should belong_to :organization }
    it { should have_many(:data_responses).dependent(:destroy) }
    it { should have_many(:reports).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of :organization_id }
    it { should validate_presence_of :title }
    it { should allow_value('2010-12-01').for(:start_date) }
    it { should_not allow_value('').for(:start_date) }
    it { should_not allow_value('2010-13-01').for(:start_date) }
    it { should_not allow_value('2010-12-41').for(:start_date) }
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
    let(:data_request) { Factory(:data_request, :start_date => "2011-01-01") }

    it "returns nil when no previous request" do
      data_request.previous_request.should be_nil
    end

    it "returns the previous request" do
      previous_request = Factory(:data_request, :start_date => "2010-01-01")

      data_request.previous_request.should == previous_request
    end
  end

  describe "#next_request" do
    let(:data_request) { Factory(:data_request, :start_date => "2011-01-01") }

    it "returns nil when no next request" do
      data_request.next_request.should be_nil
    end

    it "returns the next request" do
      next_request = Factory(:data_request, :start_date => "2012-01-01")


      data_request.next_request.should == next_request
    end
  end
end
