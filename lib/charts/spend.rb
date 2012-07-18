class Charts::Spend < Charts::Base
  def self.value_method
    :total_spend
  end
end
