module AmountType

  def is_spend?(amount_type)
    validate_amount_type(amount_type)
    amount_type == :spend
  end

  def is_budget?(amount_type)
    !is_spend?
  end

  private
  def validate_amount_type(amount_type)
    raise "Invalid amount type" unless [:budget, :spend].include?(amount_type)
  end
end
