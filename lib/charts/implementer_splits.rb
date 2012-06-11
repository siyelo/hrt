require_relative 'base'

module Charts
  module ImplementerSplits
    class Spend < Charts::Base
      def self.value_method
        :spend
      end

      def self.name_method
        :organization_name
      end
    end

    class Budget < Charts::Base
      def self.value_method
        :budget
      end

      def self.name_method
        :organization_name
      end
    end
  end
end
