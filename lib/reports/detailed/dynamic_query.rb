class Reports::Detailed::DynamicQuery
  include Reports::Detailed::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  attr_accessor :builder

  def initialize(request, amount_type, filetype)
    @deepest_nesting = Purpose.with_version(request.purposes_version).deepest_nesting
    @amount_type = amount_type
    @implementer_splits = ImplementerSplit.find :all,
      joins: { activity: :data_response },
      order: "implementer_splits.id ASC",
      conditions: ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      include: [
        { activity: [
          :targets,
          { "leaf_#{@amount_type}_purposes".to_sym => :code },
          { "leaf_#{@amount_type}_inputs".to_sym => :code },
          { "location_#{@amount_type}_splits".to_sym => :code },
          { project: { in_flows: :from } },
          { data_response: :organization },
          :implementer_splits, #eager load for activity.total_*
        ]},
        { organization: :data_responses } ]
    @builder = FileBuilder.new(filetype)
    @show_double_count = true
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  private
  def build_rows
    builder.add_row(build_header)
    @implementer_splits.each do |implementer_split|
      amount = implementer_split.activity.send(activity_total_method(@amount_type))
      build_split_rows(implementer_split) if amount && amount > 0
    end
  end

  def build_header
    row = []

    row << 'Data Source'
    row << 'Funding Source'
    row << 'Funder Type'
    row << 'Funder Raw Type'
    row << 'Implementer'
    row << 'Implementer Type'
    row << 'Implementer Raw Type'
    row << 'Project'
    row << 'On/Off Budget'
    row << 'Description of Project'
    row << 'Activity'
    row << 'Description of Activity'
    row << 'Targets'
    row << 'Input Split Total %'
    row << 'Input Split %'
    row << 'Input'
    row << 'Purpose Split Total %'
    row << 'Purpose Split %'
    row << 'Purpose'
    @deepest_nesting.times { |index| row << "Purpose #{index + 1}" }
    row << 'MTEF Code'
    row << 'NSP Code'
    row << 'Location Split Total %'
    row << 'Location Split %'
    row << 'Name of District'
    row << 'Total Amount ($)'
    row << 'Actual Double Count' if @show_double_count
    row << 'Implementer Split ID'
    row
  end

  def build_split_rows(implementer_split)
    activity = implementer_split.activity
    @currency = activity.project_id.nil? ? activity.organization.currency : activity.currency

    build_fake_classifications(activity)
    build_fake_project(activity)

    in_flows_total = activity.project.in_flows.inject(0) { |sum, e| sum + (e.send(@amount_type) || 0) }

    in_flows = in_flows_total == 0 ? loop_act = [fake_inflow(@currency)] : activity.project.in_flows

    in_flows = in_flows.sorted if in_flows.count > 1

    in_flows.each do |in_flow|
      !in_flow.send(@amount_type).nil? && in_flow.send(@amount_type) > 0
    end.each do |in_flow|
      populate_row(implementer_split, in_flow, in_flows_total)
    end
  end

  def populate_row(implementer_split, in_flow, in_flows_total)
    activity      = implementer_split.activity
    in_flow_ratio = get_ratio(in_flow.send(@amount_type), in_flows_total)

    base_row = []
    base_row << activity.organization.try(:name)
    base_row << in_flow.from.try(:name)
    base_row << in_flow.from.try(:funder_type)
    base_row << in_flow.from.try(:raw_type)
    base_row << implementer_split.organization.try(:name)
    base_row << implementer_split.organization.try(:implementer_type)
    base_row << implementer_split.organization.try(:raw_type)
    base_row << activity.project.try(:name)
    base_row << project_budget_type(activity.project)
    base_row << activity.project.try(:description)
    base_row << activity.try(:name)
    base_row << activity.try(:description)
    base_row << activity.targets.map(&:description).join(' | ')

    fake_input = is_fake?(activity.send("leaf_#{@amount_type}_inputs").first.code)
    build_incomplete_classificiation(activity, "leaf_#{@amount_type}_inputs")
    base_row << funder_ratio(activity.send("leaf_#{@amount_type}_inputs"), in_flow_ratio, fake_input)

    activity.send("leaf_#{@amount_type}_inputs").reject{|ca| ca.percentage.nil?}.sort{|a,b| b.percentage <=> a.percentage}.each do |input_classification|
      input_row = base_row.dup
      fake_purpose = is_fake?(activity.send("leaf_#{@amount_type}_purposes").first.code)

      input_row << ( fake_input ? 'N/A' : input_classification.percentage )
      input_row << input_classification.code.name
      build_incomplete_classificiation(activity, "leaf_#{@amount_type}_purposes")
      input_row << funder_ratio(activity.send("leaf_#{@amount_type}_purposes"), in_flow_ratio, fake_purpose)

      activity.send("leaf_#{@amount_type}_purposes").reject{|ca| ca.percentage.nil?}.sort{|a,b| b.percentage <=> a.percentage}.each do |purpose_classification|
        purpose_row = input_row.dup

        purpose_row << ( fake_purpose ? 'N/A' : purpose_classification.percentage.to_f.round(2) )

        purpose_row << purpose_classification.code.name

        # purpose tree
        codes = cached_self_and_ancestors(purpose_classification.code).reverse
        add_codes_to_row(purpose_row, codes, @deepest_nesting, :name)

        purpose_row << (purpose_classification.code.mtef_code.presence || 'N/A')
        purpose_row << (purpose_classification.code.nsp_code.presence || 'N/A')

        fake_district = is_fake?(activity.send("location_#{@amount_type}_splits").first.code)
        build_incomplete_classificiation(activity, "location_#{@amount_type}_splits")
        purpose_row << funder_ratio(activity.send("location_#{@amount_type}_splits"), in_flow_ratio, fake_district)

        activity.send("location_#{@amount_type}_splits").reject{|ca| ca.percentage.nil?}.sort{|a,b| b.percentage <=> a.percentage}.each do |district_classification|
          district_row = purpose_row.dup
          district_row << ( fake_district ? 'N/A' : district_classification.percentage.to_f.round(2) )
          district_row << district_classification.code.name
          district_row << in_flow_ratio *
                              ( universal_currency_converter(implementer_split.send(@amount_type),
                                                             @currency, 'USD') || 0 ) *
                                                             ( (input_classification.percentage || 0) / 100 ) *
                                                             ( (purpose_classification.percentage || 0) /100 ) *
                                                             ( (district_classification.percentage || 0) / 100)
          # don't use double_count?, we need to display if the value is nil
          district_row << implementer_split.double_count if @show_double_count
          district_row << implementer_split.id
          builder.add_row(district_row)
        end
      end
    end
  end

  def build_fake_classifications(activity)
    ["location_#{@amount_type}_splits", "leaf_#{@amount_type}_purposes",
     "leaf_#{@amount_type}_inputs"].each do |method|
       if activity.send(method).length == 0
         activity.send(method).build(percentage: 100, code: fake_code)
       end
     end
  end

  def build_incomplete_classificiation(activity, method)
    classifications = activity.send(method)
    classifications.build(percentage: incomplete_percentage(classifications),
                          code: fake_code("Not Classified")) unless fully_classified?(classifications)
  end

  def incomplete_percentage(classifications)
    100 - calculate_total_percent(classifications)
  end

  def build_fake_project(activity)
    if activity.project.blank?
      activity.project = fake_project
    end
  end

  def fake_inflow(currency)
    @fake_inflow || FundingFlow.new(from: fake_org(currency),
                                    spend: 1, budget: 1)
  end

  def fake_project
    @fake_project ||= Project.new(name: 'N/A', description: 'N/A', currency: "USD")
  end

  def fake_org(currency)
    @fake_org ||= Organization.new(name: 'N/A', currency: currency)
  end

  def fake_code(value = "N/A")
    @fake_code ||= Purpose.new(name: value, hssp2_stratprog_val: value,
                            hssp2_stratobj_val: value)
  end

  def get_ratio(amount, total)
    return 0 if amount.nil?
    total && total > 0 ? amount / total : 1
  end

  def funder_ratio(classifications, in_flow_ratio, fake)
    return 'N/A' if fake
    (calculate_total_percent(classifications) * in_flow_ratio).
      to_f.round(2)
  end

  def fully_classified?(classifications)
    return true if (calculate_total_percent(classifications) - 100).abs <= 0.5
  end

  def calculate_total_percent(classifications)
    classifications.inject(0) { |sum, p| sum + (p.percentage || 0) }
  end

  def is_fake?(in_flow)
    in_flow.id.blank?
  end

  def add_codes_to_row(row, codes, deepest_nesting, attr)
    deepest_nesting.times do |i|
      code = codes[i]
      if code
        row << code.try(attr)
      else
        row << nil
      end
    end
  end
end
