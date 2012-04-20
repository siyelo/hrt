module Activity::Classification
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def spend_classified?
      total_spend.to_i == 0 ||
      coding_spend_valid? &&
      coding_spend_district_valid? &&
      coding_spend_cc_valid?
    end

    def budget_classified?
      total_budget.to_i == 0 ||
      coding_budget_valid? &&
      coding_budget_district_valid? &&
      coding_budget_cc_valid?
    end

    # An activity can be considered classified if at least one of these are populated.
    def classified?
      budget_classified? || spend_classified?
    end

    # check if the purposes add up to 100%, regardless of what
    # activity.spend or budget is
    def purposes_classified?
      coding_spend_valid? || coding_budget_valid?
    end

    def locations_classified?
      coding_spend_district_valid? || coding_budget_district_valid?
    end

    def inputs_classified?
      coding_spend_cc_valid? || coding_budget_cc_valid?
    end

    private

      def virtual_codes(klass, code_assignments, code_ids_maping)
        CodeAssignment.send(:preload_associations, code_assignments, :code)

        assignments = []

        code_ids_maping.each do |code_name, code_ids|
          selected = code_assignments.select {|ca| code_ids.include?(ca.code.external_id)}
          code = Code.find_by_short_display(code_name)
          amount = selected.sum{|ca| ca.cached_amount}
          assignments << fake_ca(klass, code, amount)
        end

        assignments
      end

      def fake_ca(klass, code, amount, percentage = nil)
        klass.new(:activity => self, :code => code,
                  :percentage => percentage, :cached_amount => amount)
      end
  end

end
