class Reports::Detailed::DistrictWorkplan
  include CurrencyNumberHelper

  attr_accessor :request, :district, :activities, :builder, :data_responses

  def initialize(request, district, filetype)
    @request    = request
    @district   = district
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
      row << activity.implementer_splits.map(&:name).join(', ')
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
     "Budget (USD)"]
  end

  def total_row(spend_total, budget_total)
    [nil, nil, nil, 'Total', spend_total, budget_total]
  end

  def spend_district_amount(activity)
    ca = activity.location_spend_splits.detect { |ca| ca.code_id == district.id }
    amount = ca ? universal_currency_converter(ca.cached_amount, activity.currency, "USD") : 0

    amount
  end

  def budget_district_amount(activity)
    ca = activity.location_budget_splits.detect { |ca| ca.code_id == district.id }
    amount = ca ? universal_currency_converter(ca.cached_amount, activity.currency, "USD") : 0

    amount
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
