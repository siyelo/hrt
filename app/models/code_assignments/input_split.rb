class InputSplit < CodeAssignment
  named_scope :roots, lambda { { :conditions => [
    "code_assignments.code_id IN (?)",
    CostCategory.roots.map{|c| c.id}] } }

end

