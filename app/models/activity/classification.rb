module Activity::Classification
  def self.included(klass)
    klass.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def spend_classified?
      @spend_classified ||= total_spend.to_i == 0 ||
      purpose_spend_splits_valid? &&
      location_spend_splits_valid? &&
      input_spend_splits_valid?
    end

    def budget_classified?
      @budget_classified ||= total_budget.to_i == 0 ||
      purpose_budget_splits_valid? &&
      location_budget_splits_valid? &&
      input_budget_splits_valid?
    end

    # An activity can be considered classified if at least one of these are populated.
    def classified?
      @classified ||= budget_classified? || spend_classified?
    end

    # check if the purposes add up to 100%, regardless of what
    # activity.spend or budget is
    def purposes_classified?
      @purpose_classified ||= purpose_spend_splits_valid? ||
                              purpose_budget_splits_valid?
    end

    def locations_classified?
      @locations_classified ||= location_spend_splits_valid? ||
                                location_budget_splits_valid?
    end

    def inputs_classified?
      @inputs_classified ||= input_spend_splits_valid? ||
                             input_budget_splits_valid?
    end
  end
end
