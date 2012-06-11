Project.all.each do |project|
  if project.currency.blank?
    project.currency = project.organization.currency
    project.save(validate: false)
  end
end
