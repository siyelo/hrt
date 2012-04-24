FundingFlow.all.select{|ff| ff.project.nil?}.each do |ff|
  puts "Removing Funding Flow id: #{ff.id}"
  ff.destroy
end
