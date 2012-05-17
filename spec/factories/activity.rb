Factory.define :activity, :class => Activity do |f|
  f.sequence(:name) { |i| "activity_name_#{i}_#{rand(100_000_000)}" }
  f.description     { 'activity_description' }
end

Factory.define :activity_fully_coded, :class => Activity, :parent => :activity do |f|
  f.after_create { |a| Factory(:coding_spend, :percentage => 100, :activity => a) }
  f.after_create { |a| Factory(:coding_spend_district, :percentage => 100, :activity => a) }
  f.after_create { |a| Factory(:coding_spend_cost_categorization, :percentage => 100, :activity => a) }
  # Not DRY. Need to figure out how to mix two factories together
  f.after_create { |a| Factory(:coding_budget, :percentage => 100, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_district, :percentage => 100, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_cost_categorization, :percentage => 100, :activity => a) }
end


### OTHER COSTS
# Note: we dont yet define a Non-Project Indirect Cost. Simply create it by not
# passing project_id e.g.
#   oc = Factory(:other_cost_fully_coded, :data_response => @response)
#
Factory.define :other_cost, :class => OtherCost, :parent => :activity do |f|
  f.sequence(:name) { |i| "other_cost_name_#{i}" }
  f.description     { 'other cost' }
end

# To fully code an OCost, you need to do Location Splits
Factory.define :other_cost_fully_coded, :class => OtherCost, :parent => :other_cost  do |f|
  f.after_create { |a| Factory(:coding_spend_district, :percentage => 100, :activity => a) }
  f.after_create { |a| Factory(:coding_budget_district, :percentage => 100, :activity => a) }
end

