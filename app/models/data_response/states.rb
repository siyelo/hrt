module DataResponse::States
  STATES = ['unstarted', 'started', 'submitted', 'rejected', 'accepted']

  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      state_machine :state, :initial => :unstarted do
        event :start do
          transition [:unstarted] => :started
        end

        event :unstart do
          transition [:started, :submitted, :rejected, :accepted] => :unstarted
        end

        event :restart do
          transition [:started, :submitted, :rejected, :accepted] => :started
        end

        event :submit do
          transition [:started, :rejected] => :submitted
        end

        event :reject do
          transition [:submitted] => :rejected
        end

        event :accept do
          transition [:submitted] => :accepted
        end
      end
    end
  end

  module InstanceMethods
    def status
      state_to_name(state)
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
end
