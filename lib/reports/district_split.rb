require_relative 'base'
require_relative '../charts/base'

class Reports::DistrictSplit < Reports::TopBase
  include CurrencyNumberHelper
  include ActionView::Helpers::NumberHelper
  include ImplementerSplitRatio

  attr_accessor :request, :locations, :include_double_count

  def initialize(request, include_double_count = false)
    @request = request
    @locations = Location.find(:all, :order => 'short_display ASC')
    @include_double_count = include_double_count
  end

  def collection
    mark_duplicates(amounts_by_districts)
  end

  def resource_link(element)
    district_workplan_admin_reports_path(:district => element.name)
  end

  def expenditure_chart
    Charts::Spend.new(amounts_by_districts).google_column
  end

  def budget_chart
    Charts::Budget.new(amounts_by_districts).google_column
  end

  def mark_duplicates(amounts_by_districts)
    collection = super(amounts_by_districts)
    national = collection.detect{ |element| element.name == "National Level" }
    other    = collection.select{ |element| element.name != "National Level" }

    ordered_collection = []
    ordered_collection << national if national
    other.each do |element|
      ordered_collection << element
    end

    ordered_collection
  end

  private
  def amounts_by_districts
    unless @amounts
      national  = locations.detect{|l| l.short_display == 'National Level' }
      districts = locations.select{|l| l.short_display != 'National Level' }

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
    @code_splits ||= CodeSplit.find :all,
      :select => 'code_splits.type AS klass,
                  code_splits.activity_id,
                  code_splits.cached_amount AS amount,
                  codes.short_display AS district,
                  COALESCE(projects.currency, organizations.currency) AS amount_currency',
      :joins => 'INNER JOIN "codes" ON "codes".id = "code_splits".code_id
                 INNER JOIN "activities" ON "activities".id = "code_splits".activity_id
                 LEFT OUTER JOIN "projects" ON "projects".id = "activities".project_id
                 INNER JOIN "data_responses" ON "data_responses".id = "activities".data_response_id
                 INNER JOIN "organizations" ON "organizations".id = "data_responses".organization_id',
      :conditions => ["data_responses.data_request_id = ? AND
                  code_splits.type IN
                  ('LocationBudgetSplit', 'LocationSpendSplit')", request.id]
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
      method_name = method_from_class(e.klass.to_s)
      ratio = include_double_count ? 1.0 : ratios[e.activity_id.to_i][method_name]
      result[e.district][method_name] += ratio *
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


  private
  def ratios
    return @ratios if @ratios

    @ratios = {}
    code_splits.map(&:activity_id).uniq.each do |activity_id|
      @ratios[activity_id.to_i] = Hash.new(1)
    end

    implementer_splits = ImplementerSplit.joins(:activity => :data_response).
      select('implementer_splits.activity_id, implementer_splits.double_count,
             SUM(implementer_splits.budget) AS budget,
             SUM(implementer_splits.spend) AS spend').
      where(['data_request_id = ?', request.id]).
      group('implementer_splits.activity_id, implementer_splits.double_count')

    grouped_implementer_splits = implementer_splits.group_by{|is| is.activity_id}

    grouped_implementer_splits.each do |activity_id, all_splits|
      nondouble_splits = all_splits.select{|is| !is.double_count }

      activity_id = activity_id.to_i
      @ratios[activity_id] ||= Hash.new(1) # activity_id that is not classified
      @ratios[activity_id][:budget] = budget_ratio(all_splits, nondouble_splits)
      @ratios[activity_id][:spend] = spend_ratio(all_splits, nondouble_splits)
    end

    @ratios
  end
end
