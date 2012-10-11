class Classifier
  include AmountType

  attr_accessor :activity, :code_type_key, :amount_type

  def initialize(activity, code_type_key, amount_type)
    @activity = activity
    @code_type_key = code_type_key
    @amount_type = amount_type
  end

  def update_classifications(classifications)
    present_ids = []
    splits = activity.code_splits.with_code_type(code_type).
               with_amount_type(amount_type)
    codes = code_klass.find(classifications.keys)

    classifications.each_pair do |code_id, value|
      code = codes.detect{|code| code.id == code_id.to_i}

      if value.present?
        present_ids << code_id

        split = detect_assignment(splits, code_id) ||
             CodeSplit.new(activity: activity, code: code)

        split.spend = is_spend?(amount_type)
        split.percentage = value
        split.save
      end
    end

    # SQL deletion, faster than deleting records individually
    if present_ids.present?
      CodeSplit.delete_all(["activity_id = ? AND code_type = ? AND code_id NOT IN (?)",
                   activity.id, code_type, present_ids])
    else
      CodeSplit.delete_all(["activity_id = ? AND code_type = ?",
                  activity.id, code_type])
    end

    cache_updater = ClassifiedAmountCacheUpdater.new(activity)
    cache_updater.update(code_type_key, amount_type)
  end

  private
  def code_klass
    @code_klass ||= code_type.constantize
  end

  def detect_assignment(splits, code_id)
    splits.detect do |split|
      split.code_id == code_id.to_i &&
        split.code_type == code_type &&
        split.spend == is_spend?(amount_type)
    end
  end

  def code_type
    @code_type ||= code_type_key.to_s.capitalize
  end
end
