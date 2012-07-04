class OutlaysController < BaseController
  helper_method :sort_column, :sort_direction

  before_filter :confirm_activity_type, only: [:edit]
  before_filter :prevent_activity_manager, only: [:create, :update, :destroy]

  protected

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def prepare_classifications(outlay)
    # if we're viewing classification 'tabs'
    if ['locations', 'purposes', 'inputs'].include? params[:mode]
      load_klasses :mode
      @budget_coding_tree = CodingTree.new(outlay, @budget_klass)
      @spend_coding_tree  = CodingTree.new(outlay, @spend_klass)
      @budget_assignments = @budget_klass.with_activity(outlay).all.
                              map_to_hash{ |b| {b.code_id => b} }
      @spend_assignments  = @spend_klass.with_activity(outlay).all.
                              map_to_hash{ |b| {b.code_id => b} }

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

    if outlay.update_attributes(attr)
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
end
