module Project::Validations

  def validation_errors
    errors = []
    errors
  end

  def matches_in_flow_spend?
    self.total_spend == in_flows_total_spend
  end

  def matches_in_flow_budget?
    total_budget == in_flows_total_budget
  end

  def in_flows_total_spend
    in_flows_total :spend
  end

  def in_flows_total_budget
    in_flows_total :budget
  end

  private

  def in_flows_total(amount_method)
    smart_sum(in_flows, amount_method)
  end

end
