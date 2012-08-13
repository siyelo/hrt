class Reports::Detailed::DistrictWorkplan
  include CurrencyNumberHelper

  attr_accessor :request, :district, :activities, :builder, :data_responses

  def initialize(request, district, include_double_count, filetype)
    @request    = request
    @district   = district
    @include_double_count = include_double_count
    @activities = ::Activity.find :all,
      :select => 'DISTINCT activities.*, organizations.name AS org_name',
      :include => [{:data_response => [:data_request, :organization]}, :project,
                   :implementer_splits, :location_budget_splits,
                   :location_spend_splits],
      :joins => [{:data_response => :organization}, :code_splits],
      :conditions => ['code_splits.code_id = ?
                      AND data_responses.data_request_id = ?',
                      district.id, request.id],
      :order => 'organizations.name ASC'
    @builder = FileBuilder.new(filetype)
    @data_responses = @activities.map{ |a| a.data_response }
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  private
  def build_rows
    previous_activity = nil
    previous_project  = nil
    previous_organization = nil
    spend_total           = 0
    budget_total          = 0

    builder.add_row(header)
    activities.each do |activity|
      row = []

      if previous_organization && previous_organization != activity.org_name
        builder.add_row(total_row(spend_total, budget_total))
        spend_total  = 0
        budget_total = 0
      end
      spend = spend_district_amount(activity)
      budget = budget_district_amount(activity)
      spend_total  += spend
      budget_total += budget

      row << organization_name(activity, previous_organization)
      row << project_name(activity, previous_project)
      row << activity.try(:name) || 'N/A'
      if @include_double_count
        implementers = activity.implementer_splits
      else
        implementers = activity.implementer_splits.select { |is| is.double_count != true }
      end
      row << implementers.map(&:name).sort.join(', ')
      row << spend
      row << budget
      builder.add_row(row)

      previous_project = activity.project
      previous_organization = activity.org_name
    end

    builder.add_row(total_row(spend_total, budget_total))
  end

  def header
    ["Partner", "Project", "Activity", "Implementer", "Expenditure (USD)",
     "Budget (USD)" ]
  end

  def total_row(spend_total, budget_total)
    [nil, nil, nil, 'Total', spend_total, budget_total]
  end

  def spend_district_amount(activity)
    ca = activity.location_spend_splits.detect { |ca| ca.code_id == district.id }
    amount = ca ? universal_currency_converter(ca.cached_amount, activity.currency, "USD") : 0
    unless @include_double_count
      amount = amount * spend_non_double_count_ratio(activity)
    end

    amount
  end

  def budget_district_amount(activity)
    ca = activity.location_budget_splits.detect { |ca| ca.code_id == district.id }
    amount = ca ? universal_currency_converter(ca.cached_amount, activity.currency, "USD") : 0
    unless @include_double_count
      amount = amount * budget_non_double_count_ratio(activity)
    end

    amount
  end

  def double_count_ratio(activity, amount_type)
    double_counts = activity.implementer_splits.select do |is|
      is.double_count == true
    end

    unless double_counts.empty?
      double_count_amount = double_counts.inject(0) do |sum, is|
        sum + (is.send(amount_type) || 0)
      end
      total_amount = activity.send("total_#{amount_type}")
      ratio = double_count_amount / total_amount if total_amount > 0
    end

    ratio || 0
  end

  def budget_non_double_count_ratio(activity)
    1 - double_count_ratio(activity, "budget")
  end

  def spend_non_double_count_ratio(activity)
    1 - double_count_ratio(activity, "spend")
  end

  def organization_name(activity, previous_organization)
    if previous_organization != activity.org_name
      activity.org_name.presence || 'N/A'
    else
      nil
    end
  end

  def project_name(activity, previous_project)
    if previous_project != activity.project
      activity.project.try(:name) || 'N/A'
    else
      nil
    end
  end
end
