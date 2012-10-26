require File.dirname(__FILE__) + '/../spec_helper'

describe FundingFlow do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:organization_text) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:from) }
    it { should allow_mass_assignment_of(:self_provider_flag) }
    it { should allow_mass_assignment_of(:organization_id_from) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "Associations" do
    it { should belong_to :from }
    it { should belong_to :project }
    it { should belong_to :project_from }
    it { should belong_to :previous }
  end

  describe "Validations" do
    ### these break with shoulda 2.11.3 "translation missing"
    #it { should validate_presence_of(:organization_id_from) }
    # and this breaks too
    #it { should validate_numericality_of(:organization_id_from) }
    it { should validate_numericality_of(:project_from_id) }
    it { should validate_numericality_of(:budget) }
    it { should validate_numericality_of(:spend) }
  end

  describe "Custom validations" do
    before :each do
      @donor        = FactoryGirl.create(:organization)
      @organization = FactoryGirl.create(:organization)
      FactoryGirl.create :user, organization: @organization
      @request      = FactoryGirl.create(:data_request, organization: @organization)
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project, data_response: @response)
    end

    it "should validate Expenditure and/or Budget is present if nil" do
      @funding_flow = FactoryGirl.build(:funding_flow, project: @project,
                              from: @donor, budget: nil, spend: nil)
      @funding_flow.save.should == false
      @funding_flow.errors[:spend].should include(' and/or Planned must be present')
    end

    it "should validate Expenditure and/or Budget is present if blank" do
      @funding_flow = FactoryGirl.build(:funding_flow, project: @project,
                              from: @donor, budget: "", spend: "")
      @funding_flow.save.should == false
      @funding_flow.errors[:spend].should include(' and/or Planned must be present')
    end

    it "should validate spend or budget greater than 0" do
      @funding_flow = FactoryGirl.build(:funding_flow, project: @project,
                              from: @donor, budget: "0.00", spend: "0.00")
      @funding_flow.save.should == false
      @funding_flow.errors[:spend].should include('must be greater than 0')
      @funding_flow.errors[:budget].should include('must be greater than 0')

      @funding_flow = FactoryGirl.build(:funding_flow, project: @project,
                              from: @donor, budget: "0.00", spend: "222")
      @funding_flow.save.should == true

      @funding_flow = FactoryGirl.build(:funding_flow, project: @project,
                              from: @donor, budget: "", spend: "0.00")
      @funding_flow.save.should == false
      @funding_flow.errors[:spend].should include('must be greater than 0')
    end

    # in flows are saved in the context of project
    # and that's how they should be validated
    context "project" do
      context "new in flows" do
        it "cannot create project with duplicate funders" do
          basic_setup_response
          in_flow1 = FactoryGirl.build(:funding_flow, from: @organization)
          in_flow2 = FactoryGirl.build(:funding_flow, from: @organization)

          project = FactoryGirl.build(:project, data_response: @response,
                                  in_flows: [in_flow1, in_flow2])

          project.valid?.should be_false
          project.errors[:base].should include('Duplicate Project Funding Sources')
        end
      end

      context "existing in flows" do
        it "cannot create project with duplicate funders" do
          basic_setup_response
          in_flow1 = FactoryGirl.build(:funding_flow, from: @organization)

          project = FactoryGirl.build(:project, data_response: @response,
                                  in_flows: [in_flow1])

          project.save.should be_true

          in_flow2 = FactoryGirl.build(:funding_flow, from: @organization)
          project.in_flows = [in_flow1, in_flow2]
          project.valid?.should be_false
          project.errors[:base].should include('Duplicate Project Funding Sources')
        end
      end
    end
  end

  describe "more validations" do
    before :each do
      basic_setup_project
    end

    it "should validate Spend and/or Budget is present if nil" do
      @funding_flow = FactoryGirl.build(:funding_flow,
                                    spend: nil,
                                    budget: nil,
                                    project: @project,
                                    from: @organization)

      @funding_flow.valid?.should be_false
      @funding_flow.errors[:spend].should include(' and/or Planned must be present')
    end

    it "should validate Spend and/or Budget is present if blank" do
      @funding_flow = FactoryGirl.build(:funding_flow,
                                    spend: '',
                                    budget: '',
                                    project: @project,
                                    from: @organization)

      @funding_flow.valid?.should be_false
      @funding_flow.errors[:spend].should include(' and/or Planned must be present')
    end

    it "should validate one or the other" do
      @funding_flow = FactoryGirl.build(:funding_flow,
                                    spend: nil,
                                    budget: 1,
                                    project: @project,
                                    from: @organization)
      @funding_flow.valid?.should be_true

      @funding_flow.spend = 1
      @funding_flow.budget = nil
      @funding_flow.valid?.should be_true
    end
  end

  describe "currency" do
    it "returns project currency" do
      basic_setup_project
      @project.currency = "RWF"
      @project.save
      funding_flow = FactoryGirl.build(:funding_flow,
                                    project: @project,
                                    from: @organization)
      funding_flow.currency.should == "RWF"
    end
  end

  describe "#name" do
    it "returns from and to organizations in the name" do
      @request      = FactoryGirl.create :data_request
      @organization = FactoryGirl.create(:organization, name: 'Organization 2')
      FactoryGirl.create :user, organization: @organization
      @other_org    = FactoryGirl.create(:organization, name: 'ORG2')
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project, data_response: @response)

      from = FactoryGirl.create(:organization, name: 'Organization 1')
      funding_flow = FactoryGirl.create(:funding_flow, project: @project, from: from)
      funding_flow.name.should == "Project: #{@project.name}; From: #{from.name}; To: #{@organization}"
    end
  end

  describe "deprecated Response api" do
    it "should return (deprecated) response (but will do so via associated project)" do
      basic_setup_project
      from = FactoryGirl.create(:organization, name: 'Organization 1')
      to   = FactoryGirl.create(:organization, name: 'Organization 2')
      funding_flow = FactoryGirl.create(:funding_flow, project: @project, from: from)
      funding_flow.response.should == @response
      funding_flow.data_response.should == @response
    end
  end

  describe "possible double count" do
    before :each do
      basic_setup_project
      @from = FactoryGirl.create(:organization, name: 'Organization 1')
      @to   = @project.organization
    end

    it "should return true if not self funded & funding organization
        has accepted response" do
      from_user = FactoryGirl.create(:user, organization: @from)
      funding_flow = FactoryGirl.create(:funding_flow,
                                        project: @project, from: @from)
      @from.data_responses.last.accept!(User.last)
      @from.reload

      funding_flow.self_funded?.should be_false
      @from.data_responses.last.accepted?.should be_true
      funding_flow.possible_double_count?.should be_true
    end

    it "should return false if funder isn't reporting" do
      funding_flow = FactoryGirl.create(:funding_flow,
                                        project: @project, from: @from)
      @from.reporting?.should be_false
      funding_flow.possible_double_count?.should be_false
    end

    it "should return false if funding org's response isn't accepted" do
      from_user = FactoryGirl.create(:user, organization: @from)
      funding_flow = FactoryGirl.create(:funding_flow, project: @project,
                                        from: @from)

      @from.data_responses.last.accepted?.should be_false
      funding_flow.possible_double_count?.should be_false
    end

    it "should return false if funding flow is self-funded" do
      to_user = FactoryGirl.create(:user, organization: @to)
      funding_flow = FactoryGirl.create(:funding_flow, project: @project,
                                        from: @to)
      @to.data_responses.last.accept!(User.last)
      @to.reload

      funding_flow.self_funded?.should be_true
      funding_flow.possible_double_count?.should be_false
    end
  end

  describe "#mark_double_counting" do
    before :each do
      basic_setup_project
      from1 = FactoryGirl.create(:organization, name: 'Organization 1')
      from2 = FactoryGirl.create(:organization, name: 'Organization 2')
      @funding_flow1 = FactoryGirl.create(:funding_flow, project: @project,
                                          from: from1, id: 11111)
      @funding_flow2 = FactoryGirl.create(:funding_flow, project: @project,
                                          from: from2, id: 22222)
    end

    it "marks double counting from file that has text" do
      content = File.open('spec/fixtures/funder_double_count_mark_text.xls').read
      FundingFlow.mark_double_counting(content)

      @funding_flow1.reload.double_count.should be_true
      @funding_flow2.reload.double_count.should be_false
    end

    it "marks double counting from file that has number values" do
      content = File.open('spec/fixtures/funder_double_count_mark_number.xls').read
      FundingFlow.mark_double_counting(content)

      @funding_flow1.reload.double_count.should be_true
      @funding_flow2.reload.double_count.should be_false
    end

    it "marks double counting from file that has mixed values" do
      content = File.open('spec/fixtures/funder_double_count_mark_value.xls').read
      FundingFlow.mark_double_counting(content)

      @funding_flow1.reload.double_count.should be_true
      @funding_flow2.reload.double_count.should be_false
    end

    it "reset double-count marks when empty string" do
      content = File.open('spec/fixtures/funder_double_count_reset.xls').read
      FundingFlow.mark_double_counting(content)

      @funding_flow1.reload.double_count.should be_nil
      @funding_flow2.reload.double_count.should be_nil
    end
  end
end
