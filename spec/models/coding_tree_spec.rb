require File.dirname(__FILE__) + '/../spec_helper'

describe CodingTree do
  before :each do
    # Visual structure
    #
    #               / code111
    #      / code11 - code112
    # code1
    #      \ code12 - code121
    #               \ code122
    #                   - code1221
    #
    #               / code211
    #      / code21 - code212
    # code2
    #      \ code22 - code221
    #               \ code222
    #                   - code2221

    # first level
    @code1    = FactoryGirl.create(:purpose, :name => 'code1')
    @code2    = FactoryGirl.create(:purpose, :name => 'code2')

    # second level
    @code11    = FactoryGirl.create(:purpose, :name => 'code11')
    @code12    = FactoryGirl.create(:purpose, :name => 'code12')
    @code21    = FactoryGirl.create(:purpose, :name => 'code21')
    @code22    = FactoryGirl.create(:purpose, :name => 'code22')
    @code11.move_to_child_of(@code1)
    @code12.move_to_child_of(@code1)
    @code21.move_to_child_of(@code2)
    @code22.move_to_child_of(@code2)

    # third level
    @code111   = FactoryGirl.create(:purpose, :name => 'code111')
    @code112   = FactoryGirl.create(:purpose, :name => 'code112')
    @code121   = FactoryGirl.create(:purpose, :name => 'code121')
    @code122   = FactoryGirl.create(:purpose, :name => 'code122')
    @code211   = FactoryGirl.create(:purpose, :name => 'code211')
    @code212   = FactoryGirl.create(:purpose, :name => 'code212')
    @code221   = FactoryGirl.create(:purpose, :name => 'code221')
    @code222   = FactoryGirl.create(:purpose, :name => 'code222')
    @code111.move_to_child_of(@code11)
    @code112.move_to_child_of(@code11)
    @code121.move_to_child_of(@code12)
    @code122.move_to_child_of(@code12)
    @code211.move_to_child_of(@code21)
    @code212.move_to_child_of(@code21)
    @code221.move_to_child_of(@code22)
    @code222.move_to_child_of(@code22)

    # fourth level
    @code1221   = FactoryGirl.create(:purpose, :name => 'code1221')
    @code1221.move_to_child_of(@code122)
    @code2221   = FactoryGirl.create(:purpose, :name => 'code2221')
    @code2221.move_to_child_of(@code222)

    basic_setup_project
    @activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
    split    = FactoryGirl.create(:implementer_split, :activity => @activity,
                  :budget => 100, :spend => 200, :organization => @organization)
    @activity.reload
    @activity.save

  end

  describe "Tree" do
    it "has code associated" do
      ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, :purpose, :budget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots.length.should == 1
      ct.roots[0].code.should == @code1
    end

    it "has code assignment associated" do
      ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, :purpose, :budget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots.length.should == 1
      ct.roots[0].ca.should == ca1
    end

    it "has children associated (children of root)" do
      ca1  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1)
      ca11 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11)
      ct   = CodingTree.new(@activity, :purpose, :budget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots[0].children.length.should == 1
      ct.roots[0].children.map(&:ca).should == [ca11]
      ct.roots[0].children.map(&:code).should == [@code11]
    end

    it "has children associated (children of a children of a root)" do
      ca1   = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1)
      ca11  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11)
      ca111 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code111)
      ct    = CodingTree.new(@activity, :purpose, :budget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots[0].children[0].children.length.should == 1
      ct.roots[0].children[0].children.map(&:ca).should == [ca111]
      ct.roots[0].children[0].children.map(&:code).should == [@code111]
    end
  end

  describe "root" do
    it "has roots" do
      ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1)
      ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2)
      ct  = CodingTree.new(@activity, :purpose, :budget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots.length.should == 2
      ct.roots.map(&:ca).should   == [ca1, ca2]
      ct.roots.map(&:code).should == [@code1, @code2]
    end
  end

  describe "coding tree" do
    context "0.5% variance" do
      describe "budget" do
        it "is valid when there are only roots (slightly above)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 40025)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 60050)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when there are only roots (slightly below)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 39975)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 59950)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when there are only roots (slightly too much above)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 40525)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 60020)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == false
        end

        it "is valid when there are only roots (slightly to much below)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 39475)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 59950)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == false
        end
      end

      describe "spend" do
        it "is valid when there are only roots (slightly above)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 40025)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 60050)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when there are only roots (slightly below)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 39975)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 59950)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when there are only roots (slightly too much above)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 40525)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 60020)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == false
        end

        it "is valid when there are only roots (slightly to much below)" do
          @activity.stub(:total_budget).and_return(100000)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 39475)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 59950)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == false
        end
      end

      it "is valid when sum_of_children is same as parent cached_sum (2 level)" do
        ca1  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 100.5, :sum_of_children => 100)
        ca11 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11, :cached_amount => 100)
        ct   = CodingTree.new(@activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
        ct.valid?.should == true
      end

      it "is valid when sum_of_children is same as parent cached_sum (3 level)" do
        ca1   = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
        ca11  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11, :cached_amount => 100, :sum_of_children => 100)
        ca111 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code111, :cached_amount => 100)
        ct    = CodingTree.new(@activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
        ct.valid?.should == true
      end

      # looks like the amount from a child is only bubbling up 3 levels
      # something happens as moves up from 3 to 4 that it loses amounts
      it "is valid when there is one 4 levels down coding of 100% (4 level)" do
        ca1221 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1221, :percentage => 100)
        ct    = CodingTree.new(@activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
        ct.set_cached_amounts!
        ct.valid?.should == true
      end
    end

    describe "#valid?" do
      context "purposes" do
        it "is valid when activity amount is nil and classifications amount is 0" do
          @activity.stub(:total_budget).and_return(nil)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when activity amount is 0 and classifications amount is 0" do
          @activity.stub(:total_budget).and_return(nil)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 0)
          ct.stub(:root_codes).and_return([@code1]) # stub root_codes
          ct.valid?.should == true
        end

        it "is not valid when activity amount is 0 and classifications amount greater than 0" do
          @activity.stub(:total_budget).and_return(nil)
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 40)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1]) # stub root_codes
          ct.valid?.should == false
        end

        it "is valid when there are only roots" do
          ca1 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 40)
          ca2 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2, :cached_amount => 60)
          ct  = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when sum_of_children is same as parent cached_sum (2 level)" do
          ca1  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
          ca11 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11, :cached_amount => 100)
          ct   = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when sum_of_children is same as parent cached_sum (3 level)" do
          ca1   = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
          ca11  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11, :cached_amount => 100, :sum_of_children => 100)
          ca111 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code111, :cached_amount => 100)
          ct    = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        # looks like the amount from a child is only bubbling up 3 levels
        # something happens as moves up from 3 to 4 that it loses amounts
        it "is valid when there is one 4 levels down coding of 100% (4 level)" do
          ca1221 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1221, :percentage => 100)
          ct    = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.set_cached_amounts!
          ct.valid?.should == true
        end

        it "is valid when root children has lower amount" do
          ca1  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 99)
          ca11 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11, :cached_amount => 99)
          ct   = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is not valid when root children has greated amount" do
          ca1  = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 101)
          ca11 = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11, :cached_amount => 101)
          ct   = CodingTree.new(@activity, :purpose, :budget)
          ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
          ct.valid?.should == false
        end
      end

      context "locations" do
        before :each do
          @location1 = FactoryGirl.create(:location, :name => 'location1')
          @location2 = FactoryGirl.create(:location, :name => 'location2')
        end

        it "is valid when root children has no amounts for location budget" do
          ca1  = FactoryGirl.create(:location_budget_split, :activity => @activity, :code => @location1, :cached_amount => 50, :sum_of_children => 0)
          ca2  = FactoryGirl.create(:location_budget_split, :activity => @activity, :code => @location2, :cached_amount => 50, :sum_of_children => 0)
          ct   = CodingTree.new(@activity, :location, :budget)
          ct.stub(:root_codes).and_return([@location1, @location2]) # stub root_codes
          ct.valid?.should == true
        end

        it "is valid when root children has no amounts for location spend" do
          ca1  = FactoryGirl.create(:location_spend_split, :activity => @activity, :code => @location1, :cached_amount => 100, :sum_of_children => 0)
          ca2  = FactoryGirl.create(:location_spend_split, :activity => @activity, :code => @location2, :cached_amount => 100, :sum_of_children => 0)
          ct   = CodingTree.new(@activity, :location, :spend)
          ct.stub(:root_codes).and_return([@location1, @location2]) # stub root_codes
          ct.valid?.should == true
        end
      end
    end
  end

  # NOTE: these specs are done with stubing, but they need to be changed
  # to check for real objects once we remove codes seeds from test db
  describe "root_codes" do
    before :each do
      @fake_codes = [mock(:code)]
    end

    context "activity" do
      before :each do
        basic_setup_activity
      end

      it "returns root codes for purpose budget" do
        Purpose.stub(:maximum)
        Purpose.stub_chain(:with_version, :roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, :purpose, :budget)
        ct.root_codes.should == @fake_codes
      end

      it "returns root codes for input budget" do
        Input.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, :input, :budget)
        ct.root_codes.should == @fake_codes
      end

      it "returns root codes for location budget" do
        Location.should_receive(:national_level).once.and_return @fake_codes
        Location.stub_chain(:without_national_level, :sorted, :all).and_return([])

        ct = CodingTree.new(@activity, :location, :budget)
        ct.root_codes.should == @fake_codes
      end

      it "returns root codes for purpose spend" do
        Purpose.stub(:maximum)
        Purpose.stub_chain(:with_version, :roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, :purpose, :spend)
        ct.root_codes.should == @fake_codes
      end

      it "returns root codes for input spend" do
        Input.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, :input, :spend)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for location spend" do
        Location.should_receive(:national_level).once.and_return @fake_codes
        Location.stub_chain(:without_national_level, :sorted, :all).and_return([])

        ct = CodingTree.new(@activity, :location, :spend)
        ct.root_codes.should == @fake_codes
      end
    end

    context "other cost" do
      before :each do
        basic_setup_other_cost
      end

      it "returns root codes for input budget" do
        Input.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, :input, :budget)
        ct.root_codes.should == @fake_codes
      end

      it "returns root codes for location budget" do
        Location.should_receive(:national_level).once.and_return @fake_codes
        Location.stub_chain(:without_national_level, :sorted, :all).and_return([])

        ct = CodingTree.new(@other_cost, :location, :budget)
        ct.root_codes.should == @fake_codes
      end

      it "returns root codes for input spend" do
        Input.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, :input, :spend)
        ct.root_codes.should == @fake_codes
      end

      it "returns root codes for location spend" do
        Location.should_receive(:national_level).once.and_return @fake_codes
        Location.stub_chain(:without_national_level, :sorted, :all).and_return([])

        ct = CodingTree.new(@other_cost, :location, :spend)
        ct.root_codes.should == @fake_codes
      end
    end
  end

  describe "set_cached_amounts" do
    context "root code assignment" do
      it "sets cached_amount and sum_of_children for code assignment with percentage" do
        FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1,
                       :percentage => 20, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_splits.length.should == 1

        ct.roots[0].ca.cached_amount.should == 20
        ct.roots[0].ca.sum_of_children.should == 0
      end

      it "sets cached_amount and sum_of_children for code assignment with percentage" do
        cb = FactoryGirl.build(:purpose_budget_split, :activity => @activity, :code => @code1,
                       :percentage => 0.1, :cached_amount => nil, :sum_of_children => nil)
        cb.save!
        ct = CodingTree.new(@activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_splits.length.should == 1
        ct.roots[0].ca.cached_amount.should == 0.1
        ct.roots[0].ca.sum_of_children.should == 0
      end
    end

    context "root and children code assignment" do
      it "sets cached_amount and sum_of_children for 2 level code assignments with percentage" do
        FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1,
                       :percentage => 20, :cached_amount => nil, :sum_of_children => nil)
        FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code12,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_splits.length.should == 3

        ct.roots[0].ca.cached_amount.should == 20
        ct.roots[0].ca.sum_of_children.should == 20

        ct.roots[0].children[0].ca.cached_amount.should == 10
        ct.roots[0].children[0].ca.sum_of_children.should == 0

        ct.roots[0].children[1].ca.cached_amount.should == 10
        ct.roots[0].children[1].ca.sum_of_children.should == 0
      end
    end

    context "children without root code assignment" do
      it "sets cached_amount and sum_of_children when children has percentage" do
        FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code11,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_splits.length.should == 2

        ct.roots[0].ca.cached_amount.should == 10
        ct.roots[0].ca.sum_of_children.should == 10

        ct.roots[0].children[0].ca.cached_amount.should == 10
        ct.roots[0].children[0].ca.sum_of_children.should == 0
      end

      it "sets cached_amount and sum_of_children when children has percentage and activity amount is 0" do
        basic_setup_project
        activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
        split    = FactoryGirl.create(:implementer_split, :activity => @activity,
                      :budget => 1, :spend => 200, :organization => @organization)
        FactoryGirl.create(:purpose_budget_split, :activity => activity, :code => @code11,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(activity, :purpose, :budget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        activity.code_splits.length.should == 2

        ct.roots[0].ca.cached_amount.should == 0
        ct.roots[0].ca.sum_of_children.should == 0

        ct.roots[0].children[0].ca.cached_amount.should == 0
        ct.roots[0].children[0].ca.sum_of_children.should == 0
      end
    end
  end

  describe "total" do
    it "should return total for the tree" do
      FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code1,
                     :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
      FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @code2,
                     :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
      ct = CodingTree.new(@activity, :purpose, :budget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

      ct.set_cached_amounts!
      ct.reload!

      ct.total.should == 20
    end
  end

  describe "cached_children" do
    it "returns cached children" do
      ct = CodingTree.new(@activity, :purpose, :budget)
      ct.cached_children(@code1).sort.should == [@code11, @code12]
      ct.cached_children(@code2).sort.should == [@code21, @code22]
      ct.cached_children(@code11).sort.should == [@code111, @code112]
      ct.cached_children(@code12).sort.should == [@code121, @code122]
    end
  end
end
