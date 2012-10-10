require_relative 'classification_base'

module Reports
  class Inputs < Reports::ClassificationBase
    # activity: activity object
    # type:  :spend or :budget
    def splits(activity, type)
      activity.code_splits.inputs.send(type).with_codes(Input.roots)
    end
  end
end

