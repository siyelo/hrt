Project.all.each do |project|
  if project.currency.blank?
    project.currency = project.organization.currency
    project.save(false)
  end
end
