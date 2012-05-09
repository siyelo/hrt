require 'spec_helper'

class Foo
  include CurrencyNumberHelper
end

describe CurrencyNumberHelper do
  subject { Foo.new }
  before :each do
    Money.default_bank.set_rate(:EUR, :USD, 1.5)
    Money.default_bank.set_rate(:RWF, :KES, 5.0)
  end

  it "should not change the amounts when the projects currency and the data_response currency are the same" do
    subject.universal_currency_converter(1000, "EUR","EUR").should == 1000
  end

  it "should correctly convert currencies correctly when a direct conversion is possible" do
    subject.universal_currency_converter(1000, "RWF", "KES").should == 5000
  end

  describe "uses bigdecimals to avoid float arithmetic problems" do
    it "returns 1.0 on same rate" do
      subject.should_receive(:no_rate?).once.and_return true
      subject.currency_rate('RWF','RWF').class.should == BigDecimal
    end

    it "returns 1.0 on same rate" do
      subject.should_receive(:no_rate?).once.and_return false
      subject.should_receive(:direct_rate).once.and_return 12.0
      subject.currency_rate('RWF','KES').class.should == BigDecimal
    end
  end
end
