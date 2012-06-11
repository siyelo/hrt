Project.all.each do |p|
  p.budget_type = "na"
  p.save(validate: false)
end
