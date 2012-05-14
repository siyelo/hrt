class LocationSplit < CodeAssignment
  named_scope :roots, lambda { { :conditions => [
    "code_assignments.code_id IN (?)",
    Location.roots.map{|c| c.id}] } }
end

