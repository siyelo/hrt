require 'app/reports/locations'

module Reports
  class ActivityLocations < Reports::Locations
    def activities
      [@resource]
    end
  end
end

