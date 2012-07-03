require_relative 'base'

module Charts
  module ImplementerSplits
    class Spend < Charts::Base
      def self.value_method
        :total_spend
      end
    end

    class Budget < Charts::Base
      def self.value_method
        :total_budget
      end
    end
  end
end
