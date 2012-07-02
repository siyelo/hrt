module ImplementerSplitRatio

  def budget_ratio(all_splits, nondouble_splits)
    ratio = splits_sum(nondouble_splits, :budget) / splits_sum(all_splits, :budget)
    ratio.nan? ? 1.0 : ratio
  end

  def spend_ratio(all_splits, nondouble_splits)
    ratio = splits_sum(nondouble_splits, :spend) / splits_sum(all_splits, :spend)
    ratio.nan? ? 1.0 : ratio
  end

  def splits_sum(splits, amount_type)
    splits.map{|s| s.send(amount_type).to_f}.sum
  end
end
