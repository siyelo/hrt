class OtherCostsController < OutlaysController
  SORTABLE_COLUMNS = ['description', 'past expenditure', 'current budget']

  def new
    self.load_other_cost_new
  end

  def edit
    @other_cost = @response.other_costs.find(params[:id])
    prepare_edit(@other_cost)
  end

  def create
    @other_cost = @response.other_costs.new(params[:other_cost])
    save_outlay(@other_cost)
  end

  def update
    @other_cost = @response.other_costs.find(params[:id])
    update_outlay(@other_cost)
  end

  def destroy
    other_cost = @response.other_costs.find(params[:id])
    other_cost.destroy
    flash[:notice] = 'Indirect Cost was successfully destroyed'
    redirect_to projects_url
  end

  private

  def success_flash(action)
    flash[:notice] = "Indirect Cost was successfully #{action}."
  end

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "activities.name"
  end

  def confirm_activity_type
    @other_cost = OtherCost.find(params[:id])
    return redirect_to edit_activity_path(@other_cost) if @other_cost.class.eql? Activity
  end
end
