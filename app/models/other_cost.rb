class OtherCost < Activity
  include ResponseStateCallbacks

  ### Named Scopes
  scope :without_project, { :conditions => "activities.project_id IS NULL" }

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

  # Convenience method for non-project other costs
  # on the Organization Overview report
  def converted_budget
    total_budget
  end

  def converted_spend
    total_spend
  end

  # An OCost can be considered classified if the locations are classified
  def classified?
    budget_classified? && spend_classified?
  end

  #TODO: remove
  def budget_classified?
    location_budget_splits_valid? &&
    input_budget_splits_valid?
  end

  #TODO: remove
  def spend_classified?
    location_spend_splits_valid? &&
    input_spend_splits_valid?
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
#  project_id          :integer
#  user_id             :integer
#  planned_for_gor_q1  :boolean
#  planned_for_gor_q2  :boolean
#  planned_for_gor_q3  :boolean
#  planned_for_gor_q4  :boolean
#

