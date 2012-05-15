module DataResponse::States

  def status
    state_to_name
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

  def state_to_name
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

  def self.lower_state(state1, state2)
    state1_index = DataResponse::STATES.index(state1)
    state2_index = DataResponse::STATES.index(state2)
    DataResponse::STATES[[state1_index, state2_index].sort[0]]
  end

  def self.merged_response_state(duplicate_state, target_state)
    if duplicate_state == 'unstarted' || duplicate_state.nil?
      target_state
    elsif target_state == 'unstarted' || target_state.nil?
      duplicate_state
    else
      lower_state(target_state, duplicate_state)
    end
  end
end
