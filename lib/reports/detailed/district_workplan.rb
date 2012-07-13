class Reports::Detailed::DistrictWorkplan
  include CurrencyNumberHelper

  attr_accessor :request, :district, :activities, :builder, :data_responses

  def initialize(request, district, filetype)
    @request    = request
    @district   = district
    @activities = ::Activity.find :all,
      :select => 'DISTINCT activities.*, organizations.name AS org_name',
      :include => [{:data_response => [:data_request, :organization]}, :project,
                   {:implementer_splits => :organization},
                   :location_budget_splits, :location_spend_splits],
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
      activity.implementer_splits.each do |implementer_split|
        if previous_organization && previous_organization != activity.org_name
          builder.add_row(total_row(spend_total, budget_total))
          spend_total  = 0
          budget_total = 0
        end

        spend_amount  = spend_district_amount(activity, implementer_split)
        budget_amount = budget_district_amount(activity, implementer_split)

        spend_total  += spend_amount
        budget_total += budget_amount
        row = []
        row << organization_name(activity, previous_organization)
        row << project_name(activity, previous_project)
        row << activity_name(activity, previous_activity)
        row << implementer_split.name
        row << spend_amount
        row << budget_amount
        row << possible_double_count?(activity, implementer_split)
        row << implementer_split.double_count
        builder.add_row(row)

        previous_activity = activity
        previous_project = activity.project
        previous_organization = activity.org_name
      end
    end

    builder.add_row(total_row(spend_total, budget_total))
  end

  def header
    ["Partner", "Project", "Activity", "Implementer", "Expenditure (USD)",
     "Budget (USD)", 'Possible Duplicate?', "Actual Duplicate?" ]
  end

  def spend_district_amount(activity, implementer_split)
    ca = activity.location_spend_splits.detect { |ca| ca.code_id == district.id }
    amount = ca ? universal_currency_converter(ca.cached_amount, activity.currency, "USD") : 0
    (amount * implementer_spend_ratio(activity, implementer_split))
  end

  def budget_district_amount(activity, implementer_split)
    ca = activity.location_budget_splits.detect { |ca| ca.code_id == district.id }
    amount = ca ? universal_currency_converter(ca.cached_amount, activity.currency, "USD") : 0
    (amount * implementer_budget_ratio(activity, implementer_split))
  end

  def implementer_spend_ratio(activity, implementer_split)
    if activity.total_spend > 0
      (implementer_split.spend || 0) / activity.total_spend
    else
      0
    end
  end

  def implementer_budget_ratio(activity, implementer_split)
    if activity.total_budget > 0
      (implementer_split.budget || 0) / activity.total_budget
    else
      0
    end
  end

  def total_row(spend_total, budget_total)
    [nil, nil, nil, 'Total', spend_total, budget_total]
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

  def activity_name(activity, previous_activity)
    if previous_activity != activity
      activity.try(:name) || 'N/A'
    else
      nil
    end
  end

  def possible_double_count?(activity, implementer_split)
    reporting_response = activity.data_response
    if implementer_split.organization # needed for old data request
      implementing_response = data_responses.detect do |dr|
        dr.data_request_id == reporting_response.data_request_id
      end
    end

    implementer_split.check_double_count(implementing_response, reporting_response)
  end
end
