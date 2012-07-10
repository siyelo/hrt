include ClassificationsHelper

# Calculate percentage from cached amount for location budget splits
location_budget_splits = LocationBudgetSplit.where('percentage IS NULL').all
location_budget_splits_total = location_budget_splits.length

location_budget_splits.each_with_index do |assignment, index|
  puts "Setting percentage for Location Budget Split #{index+1}/#{location_budget_splits_total}"
  percentage = derive_percentage_from_amount(assignment.activity,
                                             :total_budget, assignment)

  assignment.percentage = percentage
  assignment.save!
end


# Calculate percentage from cached amount for location spend splits
location_spend_splits = LocationSpendSplit.where('percentage IS NULL').all
location_spend_splits_total = location_spend_splits.length

location_spend_splits.each_with_index do |assignment, index|
  puts "Setting percentage for Location Spend Split #{index+1}/#{location_spend_splits_total}"

  percentage = derive_percentage_from_amount(assignment.activity,
                                             :total_spend, assignment)

  assignment.percentage = percentage
  assignment.save!
end

