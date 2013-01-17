class Report < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ScriptHelper
  include AttachmentHelper

  ### Associations
  belongs_to :data_request

  ### Constants
  REPORTS = [
    'activity_overview',
    'budget_implementer_purpose',
    'spend_implementer_purpose',
    'budget_implementer_input',
    'spend_implementer_input',
    'budget_implementer_location',
    'spend_implementer_location',
    'budget_implementer_funding_source',
    'spend_implementer_funding_source',
    'budget_implementer_target',
    'spend_implementer_target',
    'budget_implementer_output',
    'spend_implementer_output',
    'budget_implementer_beneficiary',
    'spend_implementer_beneficiary',
    'budget_all_dynamic_query',
    'spend_all_dynamic_query',
    'budget_accepted_dynamic_query',
    'spend_accepted_dynamic_query',
    'funding_source_query',
    'export_response_status'
  ]

  ### Attributes
  attr_accessible :key, :attachment, :data_request_id

  ### Attachments
  has_attached_file :attachment, path:
    AttachmentHelper.attachment_path("report/:attachment/:data_request_id/:key.:extension")

  ### Validations
  validates_presence_of :key, :data_request_id
  validates_uniqueness_of :key, :scope => :data_request_id
  validates_inclusion_of :key, :in => REPORTS

  def private_url
    if private_url?
      attachment.expiring_url(3600)
    else
      attachment.url
    end
  end

  def generate_report
    create_report
  end

  def generate_report_for_download(user)
    create_report
    Notifier.report_download_notification(user, admin_reports_detailed_url(self)).deliver
  end
  handle_asynchronously :generate_report_for_download

  protected

  def report
    case key
    when 'activity_overview'
      Reports::Detailed::ActivityOverview.new(data_request, 'xls')
    when 'budget_implementer_purpose'
      Reports::Detailed::ClassificationSplit.new(data_request, :budget, :purpose, 'xls')
    when 'budget_implementer_input'
      Reports::Detailed::ClassificationSplit.new(data_request, :budget, :input, 'xls')
    when 'budget_implementer_location'
      Reports::Detailed::ClassificationSplit.new(data_request, :budget, :location, 'xls')
    when 'spend_implementer_purpose'
      Reports::Detailed::ClassificationSplit.new(data_request, :spend, :purpose, 'xls')
    when 'spend_implementer_input'
      Reports::Detailed::ClassificationSplit.new(data_request, :spend, :input, 'xls')
    when 'spend_implementer_location'
      Reports::Detailed::ClassificationSplit.new(data_request, :spend, :location, 'xls')
    when 'budget_implementer_funding_source'
      Reports::Detailed::FundingSourceSplit.new(data_request, :budget, 'xls')
    when 'spend_implementer_funding_source'
      Reports::Detailed::FundingSourceSplit.new(data_request, :spend, 'xls')
    when 'budget_implementer_target'
      Reports::Detailed::Targets.new(data_request, :budget, 'xls')
    when 'spend_implementer_target'
      Reports::Detailed::Targets.new(data_request, :spend, 'xls')
    when 'budget_implementer_output'
      Reports::Detailed::Outputs.new(data_request, :budget, 'xls')
    when 'spend_implementer_output'
      Reports::Detailed::Outputs.new(data_request, :spend, 'xls')
    when 'budget_implementer_beneficiary'
      Reports::Detailed::Beneficiaries.new(data_request, :budget, 'xls')
    when 'spend_implementer_beneficiary'
      Reports::Detailed::Beneficiaries.new(data_request, :spend, 'xls')
    when 'budget_all_dynamic_query'
      Reports::Detailed::DynamicQuery.new(data_request, :budget, 'xml', 'all')
    when 'spend_all_dynamic_query'
      Reports::Detailed::DynamicQuery.new(data_request, :spend, 'xml', 'all')
    when 'budget_accepted_dynamic_query'
      Reports::Detailed::DynamicQuery.new(data_request, :budget, 'xml', 'accepted')
    when 'spend_accepted_dynamic_query'
      Reports::Detailed::DynamicQuery.new(data_request, :spend, 'xml', 'accepted')
    when 'funding_source_query'
      Reports::Detailed::FundingSource.new(data_request, 'xls')
    when 'export_response_status'
      Reports::Detailed::ExportResponseStatus.new('xls')
    else
      raise "Invalid report request '#{self.key}'"
    end
  end

  def create_report
    report.data do |content, filetype, mimetype|
      folder = "#{Rails.root}/tmp/"
      file_name = "#{key}_#{data_request_id}_#{get_date()}.#{filetype}"

      FileZipper.zip_content(folder, file_name, content) do |zip_file_path|
        self.attachment = File.new(zip_file_path, 'r')
        self.save
      end
    end
  end
end

# == Schema Information
#
# Table name: reports
#
#  id                      :integer         not null, primary key
#  key                     :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  data_request_id         :integer
#

