class OtherCost < Activity
  include ResponseStateCallbacks

  ### Named Scopes
  scope :without_project, { conditions: "activities.project_id IS NULL" }

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

  def classified?
    @classified ||= budget_classified? && spend_classified?
  end

  def budget_classified?
    @budget_classified ||= location_budget_splits_valid? &&
                           input_budget_splits_valid?
  end

  def spend_classified?
    @spend_classified ||= location_spend_splits_valid? &&
                          input_spend_splits_valid?
  end

  def <=>(e)
    self.name <=> e.name
  end
end
