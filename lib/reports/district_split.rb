require_relative 'base'
require_relative '../charts/base'

class Reports::DistrictSplit < Reports::TopBase
  include CurrencyNumberHelper
  include ActionView::Helpers::NumberHelper

  attr_accessor :request, :locations

  def initialize(request)
    @request = request
    @locations = Location.find(:all, :order => 'short_display ASC')
  end

  def collection
    amounts_by_districts
  end

  def resource_link(element)
    district_workplan_admin_reports_path(:district => element.name)
  end

  def expenditure_chart
    Charts::Spend.new(collection).google_column
  end

  def budget_chart
    Charts::Budget.new(collection).google_column
  end

  private
  def amounts_by_districts
    unless @amounts
      national  = locations.detect{|l| l.short_display == 'National Level' }
      districts = locations.select{|l| l != national}

      @amounts = []

      @amounts << district_amounts(national) if national

      districts.each do |district|
        @amounts << district_amounts(district)
      end
    end

    @amounts
  end

  def total_budget
    @total_budget ||= amount_by_district.inject(0) do |acc, district|
      acc += district[1][:budget]
    end
    return 1 if @total_budget == 0

    @total_budget
  end

  def total_spend
    @total_spend ||= amount_by_district.inject(0) do |acc, district|
      acc += district[1][:spend]
    end
    return 1 if @total_spend == 0

    @total_spend
  end

  def amount_by_district
    @amount_by_district ||= map_data(code_splits)
  end

  def code_splits
    CodeSplit.find :all,
      :select => 'code_splits.type AS klass, codes.short_display AS district,
        SUM("code_splits".cached_amount) AS amount,
        COALESCE(projects.currency, organizations.currency) AS amount_currency',
      :joins => 'INNER JOIN "codes" ON "codes".id = "code_splits".code_id
                 INNER JOIN "activities" ON "activities".id = "code_splits".activity_id
                 LEFT OUTER JOIN "projects" ON "projects".id = "activities".project_id
                 INNER JOIN "data_responses" ON "data_responses".id = "activities".data_response_id
                 INNER JOIN "organizations" ON "organizations".id = "data_responses".organization_id',
      :conditions => ["data_responses.data_request_id = ? AND
                  code_splits.type IN
                  ('LocationBudgetSplit', 'LocationSpendSplit')", request.id],
      :group => 'klass, district, amount_currency'

  end

  def district_amounts(district)
    spend  = amount_by_district[district.short_display][:spend]
    budget = amount_by_district[district.short_display][:budget]
    Reports::Row.new(district.short_display,
                     spend.to_f.round(2),
                     budget.to_f.round(2))
  end

  def map_data(collection)
    result = {}
    locations.each { |location| result[location.short_display] ||= Hash.new(0) }

    collection.each do |e|
      result[e.district][method_from_class(e.klass.to_s)] +=
        universal_currency_converter(e.amount.to_f, e.amount_currency, 'USD')
    end

    result
  end

  def top_spenders
    national = [amounts_by_districts[0]]
    others = amounts_by_districts.drop(1)
    others.sort!{ |x, y| y.total_spend <=> x.total_spend }
    national + others
  end
end
