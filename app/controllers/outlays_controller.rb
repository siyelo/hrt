class OutlaysController < BaseController
  helper_method :sort_column, :sort_direction

  before_filter :confirm_activity_type, only: [:edit]
  before_filter :prevent_activity_manager, only: [:create, :update, :destroy]

  protected

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  # TODO: refactor
  def prepare_classifications(outlay)
    # if we're viewing classification 'tabs'
    if ['locations', 'purposes', 'inputs'].include? params[:mode]
      mode = params[:mode].singularize.to_sym # :purpose, :input, :location
      code_type = mode.to_s.capitalize # Purpose, Input, Location

      @budget_coding_tree = CodingTree.new(outlay, mode, :budget)
      @spend_coding_tree  = CodingTree.new(outlay, mode, :spend)
      @budget_assignments = outlay.code_splits.with_code_type(code_type).budget.
                              map_to_hash { |b| { b.code_id => b } }
      @spend_assignments  = outlay.code_splits.with_code_type(code_type).spend.
                              map_to_hash { |b| { b.code_id => b } }

      # set default to 'all'
      params[:view] = 'all' if params[:view].blank?
    end
  end

  # run validations on the models independently of any save action
  # useful if you want to show (existing) errors without having to save the form first.
  def load_validation_errors(resource)
    resource.implementer_splits.find(:all, include: :organization).each {|is| is.valid?}
    resource.valid?
  end

  def on_implementers_page?
    params[:mode].blank? || params[:mode] == 'implementers'
  end

  def prepare_edit(outlay)
    warn_if_not_classified(outlay)
    prepare_classifications(outlay)
    load_comment_resources(outlay)
    load_validation_errors(outlay) if on_implementers_page?
    paginate_splits(outlay) if on_implementers_page?
  end

  def save_outlay(outlay)
    if outlay.save
      success_flash("created")
      html_redirect(outlay)
    else
      paginate_splits(outlay)
      render action: 'new'
    end
  end

  def update_outlay(outlay)
    attr = outlay.class.eql?(Activity) ? params[:activity] : params[:other_cost]

    classifications = attr[:classifications]
    attr.delete :classifications

    if outlay.update_attributes(attr) &&
      update_classifications(outlay, classifications)
        success_flash("updated")
        html_redirect(outlay)
    else
      prepare_edit(outlay)
      render action: 'edit'
    end
  end

  def html_redirect(outlay)
    mode = params[:mode]
    if params[:commit]
      ['locations', 'purposes', 'inputs', 'outputs'].each do |tab|
        if params[:commit].match /#{tab}/i
          mode = tab
        end
      end

      return redirect_to projects_path if params[:commit].match /Overview/
    end

    return redirect_to edit_activity_or_ocost_path(outlay, mode: mode)
  end

  private
  def update_classifications(outlay, classifications_params)
    return true if classifications_params.blank?

    code_type_key = classifications_params.keys.first.to_sym

    unless allowed_code_type_keys(outlay).include?(code_type_key)
      raise "Invalid code type key"
    end

    classifications = classifications_params[code_type_key]
    [:budget, :spend].each do |amount_type|
      classifier = Classifier.new(outlay, code_type_key, amount_type)
      classifier.update_classifications(classifications[amount_type])
    end
  end

  def allowed_code_type_keys(outlay)
    if outlay.is_a? Activity
      [:purpose, :input, :location]
    else
      [:input, :locations]
    end
  end

end
