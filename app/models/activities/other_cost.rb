class OtherCost < Activity
  include ResponseStateCallbacks

  ### Delegates
  delegate :currency, :to => :data_response, :allow_nil => true

  ### Named Scopes
  named_scope :without_project, { :conditions => "activities.project_id IS NULL" }

  ### Callbacks
  # also check lib/response_state_callbacks

  ### Instance Methods

  # Overrides activity currency delegate method
  # some other costs does not have a project and
  # then we use the currency of the data response
  def currency
    project ? project.currency : data_response.currency
  end

  def human_name
    "Indirect Cost"
  end

  # An OCost can be considered classified if the locations are classified
  def classified?
    location_budget_splits_valid? && location_spend_splits_valid?
  end

  #TODO: remove
  def budget_classified?
    location_budget_splits_valid?
  end

  #TODO: remove
  def spend_classified?
    location_spend_splits_valid?
  end

  def <=>(e)
    self.name <=> e.name
  end
end


# == Schema Information
#
# Table name: activities
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  description         :text
#  type                :string(255)     indexed
#  other_beneficiaries :text
#  data_response_id    :integer         indexed
#  activity_id         :integer         indexed
#  approved            :boolean
#  project_id          :integer
#  am_approved         :boolean
#  user_id             :integer
#  am_approved_date    :date
#  planned_for_gor_q1  :boolean
#  planned_for_gor_q2  :boolean
#  planned_for_gor_q3  :boolean
#  planned_for_gor_q4  :boolean
#

