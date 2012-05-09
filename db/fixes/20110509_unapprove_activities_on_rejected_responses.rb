DataResponse.with_state('rejected').all.each do |data_response|
  puts "Unapproving activities for response #{data_response.id}"
  data_response.activities.each do |activity|
    puts "  Unapproving activity #{activity.id}"
    activity.approved    = false
    activity.am_approved = false
    activity.save(false)
  end
end
