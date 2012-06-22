module DataResponse::States

  def status
    state_to_name
  end

  DataResponse::STATES.each do |state_name|
    define_method "#{state_name}?" do
      state == state_name
    end
  end

  def start!(user)
    change_state_with_logs(user, "started")
  end

  def accept!(user)
    change_state_with_logs(user, "accepted")
  end

  def submit!(user)
    change_state_with_logs(user, "submitted")
  end

  def reject!(user)
    change_state_with_logs(user, "rejected")
  end

  def restart!(user)
    start!(user)
  end

  def state_to_name
    case state
    when 'unstarted'
      'Not Yet Started'
    when 'started'
      'Started'
    when 'submitted'
      'Submitted'
    when 'rejected'
      'Rejected'
    when 'accepted'
      'Accepted'
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

  private

  def change_state_with_logs(user, state)
    self.state = state
    self.response_state_logs.new(user: user)
    self.save
  end
end
