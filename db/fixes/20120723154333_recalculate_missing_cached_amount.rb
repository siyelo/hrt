LocationSpendSplit.all.select{ |sp| sp.cached_amount == 0 && sp.percentage > 0 &&
                               sp.activity.total_spend > 0 }.each_with_index do |split, index|
  puts "#{index + 1}. recalculating cached amount for LocationSpendSplit"
  split.cached_amount = split.activity.total_spend / 100 * split.percentage
  split.save!
end

LocationBudgetSplit.all.select{ |sp| sp.cached_amount == 0 && sp.percentage > 0 &&
                               sp.activity.total_budget > 0 }.each_with_index do |split, index|
  puts "#{index + 1}. recalculating cached amount for LocationBudgetSplit"
  split.cached_amount = split.activity.total_budget / 100 * split.percentage
  split.save!
end
