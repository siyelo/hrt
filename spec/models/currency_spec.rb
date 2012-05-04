require File.dirname(__FILE__) + '/../spec_helper'

describe Currency do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:from) }
    it { should allow_mass_assignment_of(:to) }
    it { should allow_mass_assignment_of(:rate) }
  end

  describe "Validations" do
    subject { Factory(:currency) }
    it { should validate_uniqueness_of(:from).scoped_to(:to) }
    it { should validate_uniqueness_of(:to).scoped_to(:from) }
    it { should validate_numericality_of(:rate) }
    it { should validate_presence_of(:from) }
    it { should validate_presence_of(:to) }
  end

  describe "update the conversion rate in the money gem" do
    it "will detect the change" do
      @currency = Factory(:currency, :from => 'BWP', :to => 'ZAR', :rate => 23)
      Money.default_bank.get_rate("BWP", "ZAR").should == 23
      @currency.rate = 24; @currency.save
      Money.default_bank.get_rate("BWP", "ZAR").should == 24
    end
  end
end
