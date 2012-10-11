require File.dirname(__FILE__) + '/../spec_helper'

describe ImplementerSplit do

  describe "Associations:" do
    it { should belong_to :activity }
    it { should belong_to :organization }
    it { should belong_to :previous }
  end

  describe "Attributes:" do
    it { should allow_mass_assignment_of(:activity_id) }
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:organization_mask) }
    it { should allow_mass_assignment_of(:organization) }
    it { should allow_mass_assignment_of(:organization_temp_name) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "Validations:" do
    it { should validate_numericality_of(:spend) }
    it { should validate_numericality_of(:budget) }

    it "should validate presence of organization_mask" do
      basic_setup_activity
      @split = ImplementerSplit.new(spend: 1, budget: 1,
                                    activity: @activity)
      @split.valid?.should be_false
      @split.errors[:organization_mask].should include("can't be blank")

      @split.organization_mask = nil
      @split.organization_id = 1
      @split.valid?.should be_true
      @split.organization_mask = 'organization_name'
      @split.organization_id = nil
      @split.valid?.should be_true
    end

    it "should validate spend/budget greater than 0" do
      basic_setup_activity
      @split = ImplementerSplit.new(activity: @activity, organization: @organization,
                                    spend: 0, budget: 0)
      @split.save.should == false
      @split.errors[:spend].should include("must be greater than 0")
      @split.errors[:budget].should include("must be greater than 0")

      @split = ImplementerSplit.new(activity: @activity, organization: @organization,
                                    spend: 0, budget: "")
      @split.save.should == false
      @split.errors[:spend].should include("must be greater than 0")

      @split = ImplementerSplit.new(activity: @activity, organization: @organization,
                                    spend: 1, budget: 0)
      @split.save.should == true
      @split.errors[:budget].should be_empty
    end

    describe "implementer uniqueness" do
      # A known rails issue ? http://stackoverflow.com/questions/5482777/rails-3-uniqueness-validation-for-nested-fields-for
      #   it "should fail when trying to create two sub-activities with the same provider via Activity nested attribute API" do

      it "should fail when trying to create two sub-activities with the same provider via Activity nested attribute API" do
        basic_setup_implementer_split
        attributes = {"name"=>"dsf",
          "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
        {"0"=> {"spend"=>"10",
          "id"=>"#{@split.id}",
          "activity_id"=>"#{@activity.id}",
          "organization_mask"=>"#{@organization.id}",
          "budget"=>"20.0"},
          "1"=> {"spend"=>"30",
            "activity_id"=>"#{@activity.id}",
            "organization_mask"=>"#{@organization.id}", "budget"=>"40.0"}
        }, "description"=>"adfasdf"}
        @activity.reload
        @activity.update_attributes(attributes).should be_false
        @activity.errors.full_messages.should include("Duplicate Implementers")
      end

      it "should enforce uniqueness via ImplementerSplit api" do
        basic_setup_implementer_split
        @split1 = FactoryGirl.create(:implementer_split, activity: @activity,
                          organization: @organization)
        @split1.should_not be_valid
        @split1.errors[:organization_id].should include("must be unique")
      end
    end
  end

  describe "Custom validations" do
    before :each do
      basic_setup_activity
    end

    it "should validate Expenditure and/or Budget is present if nil" do
      @split = ImplementerSplit.new(activity: @activity,
                                    budget: nil, spend: nil)
      @split.save.should == false
      @split.errors[:spend].should include(' and/or Budget must be present')
    end

    it "should validate Expenditure and/or Budget is present if blank" do
      @split = ImplementerSplit.new(activity: @activity,
                                    budget: "", spend: "")
      @split.save.should == false
      @split.errors[:spend].should include(' and/or Budget must be present')
    end

    it "should fail when trying to create a split without spend/budget via Activity API " do
      attributes = {"name"=>"dsf", "project_id"=>"#{@project.id}",
        "implementer_splits_attributes"=>
      {"0"=> {"spend"=>"", "budget"=>"",
        "activity_id"=>"#{@activity.id}",
        "organization_mask"=>"#{@organization.id}"},
      }, "description"=>"adfasdf"}
      @activity.reload
      @activity.update_attributes(attributes).should be_false
      @activity.implementer_splits[0].errors[:spend].should include(' and/or Budget must be present')
    end

    it "should fail when trying to create a split without spend/budget via Activity API " do
      attributes = {"name"=>"dsf", "project_id"=>"#{@project.id}",
        "implementer_splits_attributes"=>
      {"0"=> {"spend"=>"", "budget"=>"",
        "activity_id"=>"#{@activity.id}",
        "organization_mask"=>"#{@organization.id}"},
      }, "description"=>"adfasdf"}
      @activity.reload
      @activity.update_attributes(attributes).should be_false
      @activity.implementer_splits[0].errors[:spend].should include(' and/or Budget must be present')
    end

    it "should only update splits via Activity API if updated_at is set" do
      attributes = {"name"=>"dsf", "project_id"=>"#{@project.id}",
        "implementer_splits_attributes"=>
      {"0"=> {"spend"=>"1", "budget"=>"1",
        "activity_id"=>"#{@activity.id}",
        "organization_mask"=>"#{@organization.id}"},
      }, "description"=>"adfasdf"}
      @activity.reload
      @activity.update_attributes(attributes).should be_true
    end

    it "should validate one OR the other" do
      @split = ImplementerSplit.new(activity: @activity,
                                    budget: nil, spend: "123.00", organization: @organization)
      @split.save.should == true
    end
  end

  describe "#budget= and #spend=" do
    before :each do
      @split = ImplementerSplit.new
    end

    it "allows nil value" do
      @split.budget = @split.spend = nil
      @split.budget.should == nil
      @split.spend.should == nil
    end

    it "rounds up to 2 decimals" do
      @split.budget = @split.spend = 10.12745
      @split.budget.to_f.should == 10.13
      @split.spend.to_f.should == 10.13
    end

    it "rounds down to 2 decimals" do
      @split.budget = @split.spend = 10.12245
      @split.budget.to_f.should == 10.12
      @split.spend.to_f.should == 10.12
    end
  end

  it "should respond to organization_name" do
    basic_setup_implementer_split
    @split.organization_name.should == @organization.name
  end

  it "should return organization_mask as the org id" do
    org = FactoryGirl.build :organization
    split = FactoryGirl.build :implementer_split, organization: org
    split.organization_mask.should == org.name
  end

  it "should respond to assign_or_create_organization" do
    FactoryGirl.build(:implementer_split).should respond_to(:assign_or_create_organization)
  end

  it "recognizes self-implemented" do
    o = mock :org
    a = mock :activity, organization: o
    s = ImplementerSplit.new
    s.should_receive(:activity).once.and_return a
    s.should_receive(:organization).once.and_return o
    s.self_implemented?.should be_true
  end

  describe "#possible_double_count?" do
    before :each do
      @donor        = FactoryGirl.create(:organization, name: "donor")
      @organization = FactoryGirl.create(:organization, name: "self-implementer")
      user = FactoryGirl.create :user, organization: @organization
      @request      = FactoryGirl.create(:data_request, organization: @organization)
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project, data_response: @response)
      @activity     = FactoryGirl.create(:activity, project: @project,
                              data_response: @response)
    end

    context "self implementer" do
      it "does not mark double count" do
        implementer_split = FactoryGirl.create(:implementer_split, activity: @activity,
                                    organization: @organization)

        implementer_split.possible_double_count?.should be_false
      end
    end

    context "non-hrt implementer" do
      it "does not mark double count" do
        organization2 = FactoryGirl.create(:organization, raw_type: 'Non-Reporting')
        implementer_split = FactoryGirl.create(:implementer_split, activity: @activity,
                                    organization: organization2)

        implementer_split.possible_double_count?.should be_false
      end
    end

    context "another hrt implementer" do
      before :each do
        organization2 = FactoryGirl.create(:organization, name: "other-hrt-implementer")
        u = FactoryGirl.create :user, organization: organization2
        @response2     = organization2.latest_response
        project2      = FactoryGirl.create(:project, data_response: @response2)
        activity2     = FactoryGirl.create(:activity, data_response: @response2,
                                project: project2)
        @implementer_split = FactoryGirl.create(:implementer_split,
                                     activity: @activity,
                                     organization: organization2)
        FactoryGirl.create(:implementer_split, activity: activity2,
                organization: organization2)
      end
      it "marks double counting if other implementer has submitted response" do
        @response2.state = 'accepted';
        @response2.save!
        @implementer_split.reload.possible_double_count?.should be_true
      end

      it "does not marks double count if other implementer has not submitted their response" do
        @response2.state = 'started';
        @response2.save!
        @implementer_split.possible_double_count?.should be_false
      end
    end
  end

  describe "#mark_double_counting" do
    before :each do
      donor    = FactoryGirl.create(:organization, name: 'donor')
      u = FactoryGirl.create :user, organization: donor
      @request  = FactoryGirl.create(:data_request, organization: donor)
      response = donor.latest_response
      org1     = FactoryGirl.create(:organization, name: "organization1")
      org2     = FactoryGirl.create(:organization, name: "organization2")
      project  = FactoryGirl.create(:project, data_response: response)
      activity = FactoryGirl.create(:activity, id: 1, data_response: response,
                         project: project)
      @split1 = FactoryGirl.create(:implementer_split, id: 1,
                       activity: activity, organization: org1, double_count: false)
      @split2 = FactoryGirl.create(:implementer_split, id: 2,
                       activity: activity, organization: org2, double_count: false)

    end

    it "marks double counting from file that has text" do
      content = File.open('spec/fixtures/double_count_mark_text.xls').read
      ImplementerSplit.mark_double_counting(content)

      @split1.reload.double_count.should be_true
      @split2.reload.double_count.should be_false
    end

    it "marks double counting from file that has number values" do
      content = File.open('spec/fixtures/double_count_mark_number.xls').read
      ImplementerSplit.mark_double_counting(content)

      @split1.reload.double_count.should be_true
      @split2.reload.double_count.should be_false
    end

    it "marks double counting from file that has mixed values" do
      content = File.open('spec/fixtures/double_count_mark_value.xls').read
      ImplementerSplit.mark_double_counting(content)

      @split1.reload.double_count.should be_true
      @split2.reload.double_count.should be_false
    end

    it "reset double-count marks when empty string" do
      content = File.open('spec/fixtures/double_count_reset.xls').read
      ImplementerSplit.mark_double_counting(content)

      @split1.reload.double_count.should be_nil
      @split2.reload.double_count.should be_nil
    end
  end
end
