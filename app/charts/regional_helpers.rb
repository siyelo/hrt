module Charts::RegionalHelpers
  include CurrencyNumberHelper
  MTEF_CODE_LEVEL = 0 # users may not code activities to level 1 of MTEF codes
                      # so use level 0 for completeness

  def get_coding_type(code_type, is_spent)
    case code_type
    when 'nsp', 'mtef'
      is_spent ? "CodingSpend" : "CodingBudget"
    when 'cost_category'
      is_spent ? "CodingSpendCostCategorization" : "CodingBudgetCostCategorization"
    end
  end

  def get_code_klass_string(code_type)
    case code_type
    when 'nsp'
      'Nsp'
    when 'mtef'
      'Mtef'
    when 'cost_category'
      'CostCategory'
    else
      raise "Invalid code type #{code_type}".to_yaml
    end
  end

  def get_code_klass(code_type)
    case code_type
    when 'nsp'
      Nsp
    when 'mtef'
      Mtef
    when 'cost_category'
      CostCategory
    else
      raise "Invalid code type #{code_type}".to_yaml
    end
  end

  def get_codes(code_type)
    case code_type
    when 'nsp'
      Nsp.roots
    when "mtef"
      Mtef.codes_by_level(MTEF_CODE_LEVEL) # TODO: root cause of 8182669
    when 'cost_category'
      CostCategory.roots
    else
      raise "Invalid code type #{code_type}".to_yaml
    end
  end

  def get_code_assignments_for_codes_pie(code_klass_string, coding_type, activities)
    code_assignments = CodeAssignment.find(:all,
      :select => "codes.id as code_id,
                  codes.parent_id as parent_id,
                  codes.short_display AS my_name,
                  SUM(code_assignments.cached_amount_in_usd) AS value",
      :conditions => ["codes.type = ?
        AND code_assignments.type = ?
        AND activities.id IN (?)",
        code_klass_string, coding_type, activities.map(&:id)],
      :joins => [:activity, :code],
      :group => "codes.short_display, codes.id, codes.parent_id",
      :order => 'value DESC')

    remove_parent_code_assignments(code_assignments)
  end

  def remove_parent_code_assignments(code_assignments)
    parent_ids = code_assignments.collect{|n| n.parent_id} - [nil]
    parent_ids.uniq!
    parent_ids = parent_ids.map{|id| id.to_s}

    # remove cached (parent) code assignments
    # to_s is used for code_id because AR does not set proper type on joined columns
    code_assignments.reject{|ca| parent_ids.include?(ca.code_id.to_s)}
  end

  def get_hssp2_column_name(code_type)
    if code_type == 'hssp2_strat_prog'
      'hssp2_stratprog_val'
    elsif code_type == 'hssp2_strat_obj'
      'hssp2_stratobj_val'
    else
      raise "Invalid HSSP2 type #{code_type}".to_yaml
    end
  end

  def get_hssp2_coding_type(is_spent)
    is_spent ? 'CodingSpend' : 'CodingBudget'
  end

  private

    def get_summed_code_assignments(code_assignments, ratio = 1)
      values = {}

      code_assignments.each do |ca|
        if values[ca.name]
          values[ca.name] += ca.value.to_f * ratio
        else
          values[ca.name] = ca.value.to_f * ratio
        end
      end

      values.to_a
    end

    def convert_value_to_usd(records)
      records.each do |record|
        unless record.currency.blank?
          record.value = universal_currency_converter(record.value.to_f, record.currency, 'USD')
        end
      end

      records
    end
end
