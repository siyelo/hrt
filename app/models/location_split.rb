# Represents the assignment of a Location to an activity
#
# (At time of writing is used as a pseudo-aggregate of CodingBudgetDistrict & Spend equivalents
#
class LocationSplit
  attr_reader :name, :total_spend, :total_budget
  def initialize(name, spend = 0, budget = 0)
    @name = name
    @total_spend = spend
    @total_budget = budget
  end

  def <=>(x)
    self.name <=> x.name
  end
end

