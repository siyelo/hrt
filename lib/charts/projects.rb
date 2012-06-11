# require 'lib/charts/base'

module Charts
  module Projects
    class Spend < Charts::Base
      def self.value_method
        :converted_spend
      end
    end

    class Budget < Charts::Base
      def self.value_method
        :converted_budget
      end
    end
  end
end
