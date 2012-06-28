class OtherCostCode < Code; end

# Remove root codes and all children
OtherCostCode.where(parent_id: nil).each do |other_cost_code|
  puts "removing root OtherCostCode - #{other_cost_code.id}"
  other_cost_code.destroy
end

# Double check that no OtherCostCodes are left
OtherCostCode.all.each do |other_cost_code|
  puts "removing leftover OtherCostCode - #{other_cost_code.id}"
  other_cost_code.destroy
end
