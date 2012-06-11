require_relative 'inputs'

module Reports
  class ActivityInputs < Reports::Inputs
    def activities
      [@resource]
    end
  end
end

