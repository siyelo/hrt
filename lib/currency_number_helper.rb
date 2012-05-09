module CurrencyNumberHelper
  def currency_rate(from, to)
    rate = no_rate?(from, to) ? 1.0 : direct_rate(from, to)
    BigDecimal.new(rate.to_s)
  end

  def universal_currency_converter(amount, from, to)
    amount = 0 if amount.blank?
    amount * currency_rate(from, to)
  end

  private

  def no_rate?(from, to)
    from == to || from.nil? || to.nil?
  end

  def direct_rate(from, to)
    Money.default_bank.get_rate(from, to)
  end
end
