class Reports::DistrictWorkplan
  include CurrencyNumberHelper

  attr_accessor :request, :district, :activities, :builder

  def initialize(request, district, filetype)
    @request    = request
    @district   = district
    @activities = ::Activity.find :all,
      :select => 'DISTINCT activities.*,
                  organizations.name AS organization_name',
      :include => [{:data_response => :organization},
                   :project, :implementer_splits,
                   :coding_budget_district, :coding_spend_district],
      :joins => [{:data_response => :organization}, :code_assignments],
      :conditions => ['code_assignments.code_id = ?', district.id],
      :order => 'organizations.name ASC'
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  private
  def build_rows
    previous_organization = nil
    previous_project      = nil
    spend_total           = 0
    budget_total          = 0

    builder.add_row(header)
    activities.each do |activity|
      if previous_organization && previous_organization != activity.organization
        builder.add_row(total_row(spend_total, budget_total))
        spend_total  = 0
        budget_total = 0
      end

      spend_amount  = spend_district_amount(activity)
      budget_amount = budget_district_amount(activity)

      spend_total  += spend_amount
      budget_total += budget_amount
      row = []
      row << organization_name(activity, previous_organization)
      row << project_name(activity, previous_project)
      row << activity.name
      row << spend_amount
      row << budget_amount
      row << activity.implementer_splits.map { |is| is.name }.join(',')
      builder.add_row(row)

      previous_organization = activity.organization
      previous_project      = activity.project
    end

    builder.add_row(total_row(spend_total, budget_total))
  end

  def header
    ["Partner", "Project", "Activity", "Expenditure", "Budget", "Implementers"]
  end

  def spend_district_amount(activity)
    ca = activity.coding_spend_district.detect { |ca| ca.code_id == district.id }
    percentage = (ca && ca.percentage) ? ca.percentage / 100.0 : 0
    universal_currency_converter(activity.total_spend * percentage,
                                 activity.currency, "RWF")
  end

  def budget_district_amount(activity)
    ca = activity.coding_budget_district.detect { |ca| ca.code_id == district.id }
    percentage = (ca && ca.percentage) ? ca.percentage / 100.0 : 0
    universal_currency_converter(activity.total_budget * percentage,
                                 activity.currency, "RWF")
  end

  def total_row(spend_total, budget_total)
    [nil, nil, 'Total', spend_total, budget_total, nil]
  end

  def organization_name(activity, previous_organization)
    if previous_organization != activity.organization
      activity.organization.try(:name) || 'N/A'
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
