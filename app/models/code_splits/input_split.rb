class InputSplit < CodeSplit
  scope :roots, lambda { { :conditions => [
    "code_splits.code_id IN (?)",
    CostCategory.roots.map{|c| c.id}] } }

end


# == Schema Information
#
# Table name: code_splits
#
#  id              :integer         not null, primary key
#  activity_id     :integer         indexed => [code_id, type]
#  code_id         :integer         indexed => [activity_id, type], indexed
#  type            :string(255)     indexed => [activity_id, code_id]
#  percentage      :decimal(, )
#  cached_amount   :decimal(, )     default(0.0)
#  sum_of_children :decimal(, )     default(0.0)
#  created_at      :datetime
#  updated_at      :datetime
#

