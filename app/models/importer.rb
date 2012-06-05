class Importer
  include EncodingHelper

  attr_accessor :response, :rows, :filename, :projects, :activities,
    :other_costs, :new_splits, :all_projects, :all_activities, :all_splits

  # Instance variables cannot be assigned in the initializer because
  # delayed_job will not recognize them - they have to be initialized
  # within the method which is handled asynchronously
  def initialize(response, filename = '')
    @response       = response
    @filename       = filename
    @rows           ||= open_xls_or_csv(@filename)
    @projects       = []
    @activities     = []
    @other_costs    = []
    @new_splits     = []
    @all_projects   = response.projects
    @all_activities = response.activities.find(:all, :include => :implementer_splits)
    @all_splits     = @all_activities.map(&:implementer_splits).flatten

    import
  end

  private

  def import
    params = Hash.new('')

    rows.each do |row|
      params      = set_params(params, row)
      implementer = find_implementer(params)

      if is_other_without_a_project?(params)
        other_cost  = find_activity(nil, params, OtherCost)
        split       = find_split(other_cost, implementer, params)

        other_costs << other_cost unless other_costs.include?(other_cost)
      else
        project     = find_project(params)
        activity    = find_activity(project, params, Activity)
        split       = find_split(activity, implementer, params)

        projects   << project  unless projects.include?(project)
        activities << activity unless activities.include?(activity)
      end

    end

    mark_splits_for_destruction
    new_splits.each { |split| split.activity.implementer_splits << split }
    check_projects_activities_valid(projects, activities) # TODO: refactor
  end

  def is_other_without_a_project?(params)
    project_name = params.fetch(:project_name)
    project_description = params.fetch(:project_description)
    project_end_date = params.fetch(:project_end_date)
    project_start_date = params.fetch(:project_start_date)
    project_budget_type = params.fetch(:project_budget_type)

    [project_name, project_description, project_end_date,
        project_start_date, project_budget_type].all? { |e| e == 'N/A' }
  end

  def set_params(params, row)
    # determine project & activity details depending on blank rows
    params[:implementer_name] = sanitize_encoding(row['Implementer'].try(:strip))
    params[:split_id] = row['Id']
    params[:activity_name] = name_for(row['Activity Name'], params[:activity_name])
    params[:activity_description] = description_for(row['Activity Description'],
                             params[:activity_description], row['Activity Name'])
    params[:project_name]         = name_for(row['Project Name'], params[:project_name])
    params[:project_description]  = description_for(row['Project Description'],
                             params[:project_description], row['Project Name'])
    params[:project_budget_type]  = name_for(row['On/Off Budget'], params[:project_budget_type])
    params[:project_start_date]   = row['Project Start Date']
    params[:project_end_date]     = row['Project End Date']
    params[:spend]                = row["Past Expenditure"]
    params[:budget]               = row["Current Budget"]
    params
  end

  def check_projects_activities_valid(projects, activities)
    projects.each { |p| p.valid? }
    activities.each { |a| a.valid? }
    activities.map(&:implementer_splits).flatten.each do |is|
      is.errors.add(:organization_temp_name, "does not exist") if is.organization_mask.blank?
    end
  end

  def create_self_funder(project)
    FundingFlow.new(:organization_id_from => project.organization.id,
                    :spend => 1, :budget => 1)
  end

  def create_new_implementer_split(activity, implementer_name)
    # dont use activity.implementer_splits.new, it loads a new association obj
    split = ImplementerSplit.new(:organization_temp_name => implementer_name)
    split.activity = activity
    new_splits << split
    split
  end


  def mark_splits_for_destruction
    activities.map(&:implementer_splits).flatten.each do |is|
      is.mark_for_destruction unless is.changed?
    end
  end

  def open_xls_or_csv(filename)
    begin
      worksheet = Spreadsheet.open(filename).worksheet(0)
      rows = create_hash_from_header(worksheet)
    rescue Ole::Storage::FormatError
      # try import the file as a csv if it is not an spreadsheet
      rows = FasterCSV.open(filename, {:headers => true, :skip_blanks => true})
    end

    rows
  end

  def create_hash_from_header(xls_worksheet)
    rows = []
    header = []
    xls_worksheet.each_with_index do |row, row_index|
      if row_index == 0
        header = row
      else
        h = Hash.new
        row.each_with_index do |cell, col_index|
          h[header[col_index]] = cell
        end
        rows << h
      end
    end
    rows
  end

  def name_for(current_row_name, previous_name)
    name = sanitize_encoding(current_row_name.blank? ? previous_name : current_row_name)
    name = name.strip.slice(0..Project::MAX_NAME_LENGTH-1).strip # strip again after truncation in case there are
                                                                 # any trailing spaces
  end

  # return the previous description only if both description and name
  # from current row are blank
  def description_for(desc, prev_desc, name)
    description = desc.blank? && name.blank? ? prev_desc : desc
    sanitize_encoding(description).to_s.strip
  end

  def date_for(date_row, existing_date)
    if date_row.blank? && existing_date
      existing_date
    else
      DateHelper::flexible_date_parse(date_row)
    end
  end

  def find_implementer(params)
    implementer_name = params.fetch(:implementer_name)
    return nil if implementer_name.blank?
    find_implementer_by_full_name(implementer_name) ||
      find_implementer_by_first_word(implementer_name)
  end

  def find_implementer_by_full_name(implementer_name = '')
    Organization.find(:first, :conditions => [ "LOWER(name) LIKE ?",
        "%#{implementer_name.downcase}%"])
  end

  def find_implementer_by_first_word(implementer_name = '')
    Organization.find(:first, :conditions => [ "LOWER(name) LIKE ?",
        "#{implementer_name.split(' ')[0].downcase}%"])
  end

  # finds project in memory, db or creates new one
  def find_project(params)
    split_id = params.fetch(:split_id)
    project_name = params.fetch(:project_name)
    project_description = params.fetch(:project_description)
    project_end_date = params.fetch(:project_end_date)
    project_start_date = params.fetch(:project_start_date)
    project_budget_type = params.fetch(:project_budget_type)

    project = find_cached_project(split_id)
    project ||= projects.detect { |p| p.name == project_name }
    project ||= all_projects.detect { |p| p.name == project_name }
    project ||= response.projects.new(:budget_type => "on",
                 :currency => response.organization.currency)

    project.attributes = { :data_response_id => response.id,
     :name => project_name, :budget_type => project_budget_type,
     :description => project_description,
     :start_date => date_for(project_start_date, project.start_date),
     :end_date => date_for(project_end_date, project.end_date)}
    project.in_flows << create_self_funder(project) if project.in_flows.empty?
    project
  end

  # finds activity in memory, db or creates new one
  def find_activity(project, params, klass)
    split_id             = params.fetch(:split_id)
    activity_name        = params.fetch(:activity_name)
    activity_description = params.fetch(:activity_description)

    activity = find_cached_activity(split_id)
    activity ||= activities.detect do |a|
      a.name == activity_name && a.project && a.project.name == project.name
    end
    activity ||= all_activities.detect { |a| a.name == activity_name }
    activity ||= klass.new
    activity.attributes = { :data_response_id => response.id,
      :project_id => project.try(:id), :name => activity_name,
      :description => activity_description }
    activity.project = project
    activity
  end

  def find_split(activity, implementer, params)
    implementer_name = params.fetch(:implementer_name)
    split = find_cached_split(params.fetch(:split_id))
    split ||= activity.implementer_splits.detect { |s| s.organization_id == implementer.id } if implementer
    #split = activity.implementer_splits.find(:first,
                    #:conditions => { :organization_id => implementer.id}) if implementer
    split ||= create_new_implementer_split(activity, implementer_name)
    split = activity.implementer_splits.detect{ |is| is.id == split.id } || split # TODO: refactor
    split.attributes = { :organization => implementer,
                         :organization_temp_name => implementer_name,
                         :spend => params.fetch(:spend),
                         :budget => params.fetch(:budget) }
    split.organization_id_will_change!
    split
  end

  def find_cached_project(split_id)
    activity = find_cached_activity(split_id)
    all_projects.detect { |p| p.id == activity.project_id } if activity
  end

  def find_cached_activity(split_id)
    split = find_cached_split(split_id)
    all_activities.detect { |a| a.id == split.activity_id } if split
  end

  def find_cached_split(split_id)
    all_splits.detect{|split| split.id == split_id.to_i}
  end
end
