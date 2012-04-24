organizations = Organization.nonreporting.find(:all, :include => :data_responses)
total = organizations.length
organizations.each_with_index do |organization, index|
  puts "#{index + 1}/#{total} Removing responses for organization #{organization.id}"
  organization.data_responses.each do |data_response|
    if data_response.projects.blank?
      data_response.destroy
    end
  end
end
