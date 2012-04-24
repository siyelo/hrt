organization = Organization.find_by_name("USAID Admin")
if organization
  organization.raw_type = 'Bilateral'
  organization.save(false)
end

organization = Organization.find_by_name("internal_for_dev2")
if organization
  organization.raw_type = 'Bilateral'
  organization.save(false)
end

organization = Organization.find_by_name("E-Health/MOH")
if organization
  organization.raw_type = 'MOH central'
  organization.save(false)
end

organization = Organization.find_by_name("University of Maryland")
if organization
  organization.raw_type = 'International NGO'
  organization.save(false)
end

organization = Organization.find_by_name("hj")
if organization
  organization.raw_type = 'Bilateral'
  organization.save(false)
end

organization = Organization.find_by_name("KAGENO RWANDA PROJECT")
if organization
  organization.raw_type = 'Local NGO'
  organization.save(false)
end

organization = Organization.find_by_name("TRAC Plus   ")
if organization
  organization.raw_type = 'International NGO'
  organization.save(false)
end

organization = Organization.find_by_name("_admin_organization")
if organization
  organization.raw_type = 'Bilateral'
  organization.save(false)
end

organization = Organization.find_by_name("Kibogora HD District Hospital | Nyamasheke")
if organization
  organization.raw_type = 'National Hospital'
  organization.save(false)
end
