require_relative 'locations'

module Reports
  class ActivityLocations < Reports::Locations
    def activities
      [@resource]
    end
  end
end

