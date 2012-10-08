class Classifier
  include AmountType

  attr_accessor :activity, :code_type, :amount_type

  def initialize(activity, code_type, amount_type)
    @activity = activity
    @code_type = code_type
    @amount_type = amount_type
  end

  def update_classifications(classifications)
    present_ids = []
    assignments = activity.code_splits.with_code_type(code_type).
      with_amount_type(amount_type)
    codes = code_klass.find(classifications.keys)

    classifications.each_pair do |code_id, value|
      code = codes.detect{|code| code.id == code_id.to_i}

      if value.present?
        present_ids << code_id

        ca = find_assignment(assignments, code_id) ||
             new(activity: activity, code: code)

        ca.is_spend = is_spend?(amount_type)
        ca.percentage = value
        ca.save
      end
    end

    # SQL deletion, faster than deleting records individually
    if present_ids.present?
      delete_all(["activity_id = ? AND code_type = ? AND code_id NOT IN (?)",
                   activity.id, code_type, present_ids])
    else
      delete_all(["activity_id = ? AND code_type = ?",
                  activity.id, code_type])
    end

    activity.update_classified_amount_cache(code_type, amount_type)
  end

  private
  def code_klass
    code_type.to_s.capitalize.constantize
  end

  def find_assignment(assignments, code_id)
    assignments.detect do |ca|
      ca.code_id == code_id.to_i &&
        ca.code_type == code_type &&
        ca.is_spend == is_spend?(amount_type)
    end
  end
end
