class Importer
  include EncodingHelper

  attr_accessor :response, :file, :filename, :projects, :activities, :new_splits

  # Instance variables cannot be assigned in the initializer because
  # delayed_job will not recognize them - they have to be initialized
  # within the method which is handled asynchronously
  def initialize(response, filename = '')
    @response   = response
    @filename   = filename
    @file       ||= open_xls_or_csv(@filename)
    @projects   = []
    @activities = []
    @new_splits = []
    import
  end

  def save
    projects.each do |project|
      project_activities = activities.find_all{ |a| a.project == project }
      project.activities << project_activities
      project.save(false)
    end
  end
  handle_asynchronously :save # NEEDS TO BE MOVED TO SERVICE CLASS

  private

    def check_projects_activities_valid(projects, activities)
      projects.each{ |p| p.valid?}
      activities.each{ |a| a.valid?}
    end

    def create_self_funder(project)
      ff                      = FundingFlow.new
      ff.organization_id_from = project.organization.id
      ff.spend                = 1
      ff.budget               = 1
      ff
    end

    def create_new_implementer_split(activity)
      # dont use activity.implementer_splits.new, it loads a new association obj
      split = ImplementerSplit.new
      split.activity = activity
      @new_splits << split
      split
    end

    def assign_split_fields(split, implementer, spend, budget)
      split.organization  = implementer
      split.spend         = spend
      split.budget        = budget
      split.organization_id_will_change!
    end

    def import
      activity_name = project_name = ''
      project_description = activity_description = ''
      project_budget_type = ''
      @new_splits = []

      @file.each do |row|
        # determine project & activity details depending on blank rows
        activity_name        = name_for(row['Activity Name'], activity_name)
        activity_description = description_for(row['Activity Description'],
                                 activity_description, row['Activity Name'])
        project_name         = name_for(row['Project Name'], project_name)
        project_description  = description_for(row['Project Description'],
                                 project_description, row['Project Name'])
        project_budget_type  = name_for(row['On/Off Budget'], project_budget_type)
        project_start_date   = row['Project Start Date']
        project_end_date     = row['Project End Date']
        sub_activity_name    = sanitize_encoding(row['Implementer'].try(:strip))
        sub_activity_id      = row['Id']

        # find implementer based on name or set self-implementer if not found
        # or row is left blank
        implementer = find_implementer(sub_activity_name)

        split = activity = project = nil

        # try find the split based on the id
        # use the association, not AR find, so we reference the same object
        split = find_cached_split(sub_activity_id)
        split = ImplementerSplit.find_by_id(sub_activity_id) unless split

        activity = find_cached_activity(sub_activity_id)

        #split ID is present and valid - use split's activity & project
        if split
          activity = split.activity unless activity
          project  = activity.project
        else
          # split ID not present or invalid
          # try find activity from activities in memory,
          @activities.each do |a|
            if a.name == activity_name && a.project.name == project_name
              activity = a
              project = a.project
            end
          end

          #if activity not found in memory, try find the project in memory
          @projects.each do |p|
            project = p if p.name == project_name
          end

          project = @response.projects.find_by_name(project_name) unless project
          project = @response.projects.new(:budget_type => "on",
                       :currency => @response.organization.currency) unless project
          activity = project.activities.find_by_name(activity_name) unless activity
          activity = Activity.new unless activity
          activity.project = project
          split = activity.implementer_splits.find(:first,
                          :conditions => { :organization_id => implementer.id}) if implementer
          split = create_new_implementer_split(activity) unless split
        end

        # at this point, we should have an activity, and since we save everything via activity,
        # we need to use the activity objects

        # try find the split based on the id. use the association, not AR find,
        # so we reference the same object. (AR find might pull out a new object)
        split = activity.implementer_splits.detect{ |is| is.id == split.id } || split

        project.attributes = { :data_response_id => @response.id,
         :name => project_name, :budget_type => project_budget_type,
         :description => project_description,
         :start_date => date_for(project_start_date, project.start_date),
         :end_date => date_for(project_end_date, project.end_date)}
        project.in_flows << create_self_funder(project) if project.in_flows.empty?
        activity.attributes = { :data_response_id => @response.id,
          :project_id => project.id, :name => activity_name,
          :description => activity_description}

        assign_split_fields(split, implementer, row["Past Expenditure"], row["Current Budget"])

        @activities << activity unless @activities.include?(activity)
        @projects << project unless @projects.include?(project)
      end

      check_projects_activities_valid(@projects, @activities)
      mark_splits_for_destruction
      @new_splits.each do |split|
        split.activity.implementer_splits << split
      end
    end

    def mark_splits_for_destruction
      @activities.map(&:implementer_splits).flatten.each do |is|
        is.mark_for_destruction unless is.changed?
      end
    end

    def open_xls_or_csv(filename)
      begin
        worksheet = Spreadsheet.open(filename).worksheet(0)
        file = create_hash_from_header(worksheet)
      rescue Ole::Storage::FormatError
        # try import the file as a csv if it is not an spreadsheet
        file = FasterCSV.open(filename, {:headers => true, :skip_blanks => true})
      end

      file
    end

    def create_hash_from_header(xls_worksheet)
      file = []
      header = []
      xls_worksheet.each_with_index do |row, row_index|
        if row_index == 0
          header = row
        else
          h = Hash.new
          row.each_with_index do |cell, col_index|
            h[header[col_index]] = cell
          end
          file << h
        end
      end
      file
    end

    def name_for(current_row_name, previous_name)
      name = sanitize_encoding(current_row_name.blank? ? previous_name : current_row_name)
      name = name.strip.slice(0..Project::MAX_NAME_LENGTH-1).strip # strip again after truncation in case there are
                                                                   # any trailing spaces
    end

    # return the previous description only if both description and name
    # from current row are blank
    def description_for(description, previous_description, name)
      result = description
      if description.blank? && name.blank?
        result = previous_description
      end
      sanitize_encoding(result).to_s.strip
    end

    def date_for(date_row, existing_date)
      if date_row.blank? && existing_date
        date = existing_date
      else
        date = DateHelper::flexible_date_parse(date_row)
      end
      date
    end

    def find_implementer(implementer_name)
      implementer = nil
      unless implementer_name.blank?
        implementer = find_implementer_by_full_name(implementer_name) ||
          find_implementer_by_first_word(implementer_name) ||
          implementer
      end
      implementer
    end

    def find_implementer_by_full_name(implementer_name = '')
      Organization.find(:first, :conditions => [ "LOWER(name) LIKE ?",
          "%#{implementer_name.downcase}%"])
    end

    def find_implementer_by_first_word(implementer_name = '')
      Organization.find(:first, :conditions => [ "LOWER(name) LIKE ?",
          "#{implementer_name.split(' ')[0].downcase}%"])
    end


    def find_cached_activity(implementer_split_id)
      split = find_cached_split(implementer_split_id)
      @activities.detect { |a| a.id == split.activity_id } if split
    end

    def find_cached_split(implementer_split_id)
      @activities.map(&:implementer_splits).flatten.detect do |is|
        is.id == implementer_split_id.to_i
      end
    end
end
