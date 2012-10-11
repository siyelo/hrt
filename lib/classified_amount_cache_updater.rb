class ClassifiedAmountCacheUpdater
  def initialize(activity)
    @activity = activity
  end

  def update_all
    [:purpose, :location, :input].each do |code_type_key|
      [:budget, :spend].each do |amount_type|
        update(code_type_key, amount_type)
      end
    end
  end

  def update(code_type_key, amount_type)
    # disable update_all_classified_amount_caches
    # callback to be run again on save !!
    Activity.skip_callback(:update, :before, :update_all_classified_amount_caches)
    set_classified_amount_cache(code_type_key, amount_type)
    @activity.save(validate: false)
  end
  handle_asynchronously :update

  private
  def set_classified_amount_cache(code_type_key, amount_type)
    coding_tree = CodingTree.new(@activity, code_type_key, amount_type)
    coding_tree.set_cached_amounts!
  end
end
