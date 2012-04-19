require File.dirname(__FILE__) + '/../spec_helper'

class Foo
  include CurrencyHelper
end

describe CurrencyHelper do
  before :all do
    load 'currencies_load_script.rb'
  end

  before :each do
    Money.default_bank.set_rate(:RWF, :USD, 1)
    Money.default_bank.set_rate(:USD, :USD, 1)
    Money.default_bank.set_rate(:EUR, :USD, 1)
    Money.default_bank.set_rate(:CHF, :USD, 1)
    @foo = Foo.new
  end

  it "should return the currency for select" do
    @foo.currency_options_for_select.should include(["Euro (EUR)", "EUR"])
  end

  describe "no _to_usd exchange rate" do
    it "should not return a currency for select" do
      Money.default_bank.set_rate(:BZD, :USD, nil)
      @foo.currency_options_for_select.should_not include(["Belize Dollar (BZD)", "BZD"])
    end
  end
end
