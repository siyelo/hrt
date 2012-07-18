class Charts::Budget < Charts::Base
  def self.value_method
    :total_budget
  end
end
