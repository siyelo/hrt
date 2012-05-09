module DataResponse::States

  def status
    state_to_name(state)
  end

  DataResponse::STATES.each do |state_name|
    define_method "#{state_name}?" do
      state == state_name
    end
  end

  def reject!
    self.state = 'rejected'
    self.activities.each do |activity|
      activity.approved    = false
      activity.am_approved = false
      activity.save(false)
    end
    self.save!
  end

  def start!
    self.state = 'started'
    self.save!
  end

  def restart!
    start!
  end

  def accept!
    self.state = 'accepted'
    self.save!
  end

  def submit!
    self.state = 'submitted'
    self.save!
  end

  def state_to_name(state)
    case state
    when 'unstarted' : 'Not Yet Started'
    when 'started'   : 'Started'
    when 'submitted' : 'Submitted'
    when 'rejected'  : 'Rejected'
    when 'accepted'  : 'Accepted'
    end
  end

  def name_to_state(filter)
    case filter
    when 'Not Yet Started' : 'unstarted'
    when 'Started'         : 'started'
    when 'Submitted'       : 'submitted'
    when 'Rejected'        : 'rejected'
    when 'Accepted'        : 'accepted'
    end
  end
end
