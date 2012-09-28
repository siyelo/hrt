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

  describe "AliasAttributes" do
    it "assigns name" do
      dr = FactoryGirl.build(:data_request, :title => "blar")
      dr.name.should == "blar"
    end
  end

  describe "Callbacks" do
    # after_create :create_data_responses
    it "creates data_responses for each reporting organization after data_request is created" do
      org1 = FactoryGirl.create(:organization)
      FactoryGirl.create :user, :organization => org1
      org2 = FactoryGirl.create(:organization)
      FactoryGirl.create :user, :organization => org2
      data_request = FactoryGirl.create(:data_request, :organization => org1)
      data_request.data_responses.count.should == 2
      organizations = data_request.data_responses.map(&:organization)

      organizations.should include(org1)
      organizations.should include(org2)
    end

    it "does not create data_responses for Non-Reporting organizations" do
      org = FactoryGirl.create(:organization, :raw_type => 'Non-Reporting')
      FactoryGirl.create(:data_request, :organization => org)

      org.data_responses.should be_empty
    end

    it "assigns code type versions on create" do
      FactoryGirl.create(:location, version: 1)
      FactoryGirl.create(:mtef_code, version: 2)
      FactoryGirl.create(:input, version: 3)
      FactoryGirl.create(:beneficiary, version: 4)

      data_request = FactoryGirl.create(:data_request)
      data_request.locations_version.should == 1
      data_request.purposes_version.should == 2
      data_request.inputs_version.should == 3
      data_request.beneficiaries_version.should == 4
    end
  end

  describe "#previous_request" do
    let(:data_request) { FactoryGirl.create(:data_request, :start_date => "2011-01-01") }

    it "returns nil when no previous request" do
      data_request.previous_request.should be_nil
    end

    it "returns the previous request" do
      previous_request = FactoryGirl.create(:data_request, :start_date => "2010-01-01")

      data_request.previous_request.should == previous_request
    end
  end

  describe "#next_request" do
    let(:data_request) { FactoryGirl.create(:data_request, :start_date => "2011-01-01") }

    it "returns nil when no next request" do
      data_request.next_request.should be_nil
    end

    it "returns the next request" do
      next_request = FactoryGirl.create(:data_request, :start_date => "2012-01-01")
      data_request.next_request.should == next_request
    end
  end
end
