Activity.where('name is null').each do |activity|
  activity.name = 'Unnamed Activity'
  activity.save(validate: false)
end
