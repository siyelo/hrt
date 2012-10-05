class PurposeSplit < CodeSplit
  def self.update_classifications(activity, classifications)
    super(activity, Purpose, classifications)
  end
end
