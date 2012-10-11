class Reports::Detailed::FunctionalWorkplan
  include Reports::Detailed::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  attr_accessor :builder

  def initialize(response, organizations, filetype)
    @response = response
    if organizations
      @organizations = organizations.sorted
    else
      @organizations = [response.organization]
    end
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  protected
  def build_rows
    builder.add_row(header)
    @organizations.each do |organization|
      org_response = organization.responses.find(:first,
                      conditions: "data_request_id = #{@response.request.id}")
      if org_response
        row = []
        row << organization.name
        if org_response.projects.empty? && org_response.other_costs.without_project.empty?
          builder.add_row(row)
          row = []
        else
          unless org_response.projects.empty?
            build_project_rows(row, org_response)
            row = []
          end

          unless org_response.other_costs.without_project.empty?
            build_other_cost_without_project_rows(row, org_response)
          end
        end
      end
    end
  end

  def header
    row = []
    row << "Organization Name"
    row << "Project Name"
    row << "Project Description"
    row << "Funding Sources"
    row << "Activity Name"
    row << "Activity Description"
    row << "Type"
    row << "Activity Expenditure ($)"
    row << "Activity Budget ($)"
    row << "Implementers"
    row << "Targets"
    row << "Outputs"
    row << "Beneficiaries"
    row << "Districts worked in/National focus"
    row
  end

  def add_project_columns(project, index, row)
    row << "" if index > 0
    row << project.name
    row << project.description
    row << project.in_flows.map{|ff| ff.from.name}.join(',')
    row
  end

  def add_activity_columns(activity, index, row)
    klass = activity.class == OtherCost ? 'Indirect Cost' : activity.class.to_s.titleize
    4.times do
      row << "" if index > 0
    end
    row << nice_activity_name(activity, 50)
    row << activity.description
    row << klass
    row << universal_currency_converter(activity.total_spend, activity.currency, 'USD')
    row << universal_currency_converter(activity.total_budget, activity.currency, 'USD')
    row << activity.implementer_splits.map{|is| is.organization_name}.join(', ')
    row << activity.targets.map{ |e| e.description }.join(', ')
    row << activity.outputs.map{ |e| e.description }.join(', ')
    row << activity.beneficiaries.map{ |e| e.short_display }.join(', ')
    row << activity.locations.map{ |e| e.short_display }.join(', ')
    row
  end

  def nice_activity_name(activity, length)
    nice_name = ApplicationController.helpers.friendly_name(activity, length)
    nice_name
  end

  def build_project_rows(row, org_response)
    org_response.projects.sorted.each_with_index do |project, index|
      row = add_project_columns(project, index, row)
      if project.activities.empty?
        builder.add_row(row)
        row = []
      else
        project.activities.sorted.each_with_index do |activity, index|
          row = add_activity_columns(activity, index, row)
          builder.add_row(row)
          row = []
        end
      end
    end
  end

  def build_other_cost_without_project_rows(row, org_response)
    org_response.other_costs.without_project.sorted.each do |ocost|
      row = add_activity_columns(ocost, 1, row)
      builder.add_row(row)
      row = []
    end
  end
end
