module TreeHelpers
  def deepest_nesting
    levels = roots_with_level.collect{|a| a[0]}
    levels.present? ? (levels.max + 1) : 0
  end

  # can be removed if we refactor self.deepest_nesting
  def roots_with_level
    a = []
    roots.each do |root|
      each_with_level(root.self_and_descendants) do |code, level|
        a << [level, code.id]
      end
    end
    a
  end
end
