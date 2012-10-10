require_relative 'classification_base'

module Reports
  class Locations < Reports::ClassificationBase
    # activity: activity object
    # type:  :spend or :budget
    def splits(activity, type)
      activity.code_splits.locations.send(type)
    end
  end
end
