#
# All concerns/behaviours related to DR state management
#
# Reopened class since state_machine seems to only respond
# to ActiveRecord::Base classes
class DataResponse < ActiveRecord::Base
  STATES = ['unstarted', 'started', 'submitted', 'rejected', 'accepted']

  # Validations
  validates_inclusion_of  :state, :in => STATES

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

  module States
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

    def self.included(base)
      base.send(:include, InstanceMethods)
    end
  end
end
