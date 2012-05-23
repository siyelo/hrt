Project.all.each do |p|
  p.budget_type = "na"
  p.save(false)
end
