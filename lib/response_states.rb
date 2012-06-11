module ResponseStates

  def name_to_state(filter)
    case filter
    when 'Not Yet Started'
      'unstarted'
    when 'Started'
      'started'
    when 'Submitted'
      'submitted'
    when 'Rejected'
      'rejected'
    when 'Accepted'
      'accepted'
    end
  end
end
