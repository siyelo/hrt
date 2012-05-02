require 'iconv'
require 'lib/script_helper'
require 'lib/private_url'

class Report < ActiveRecord::Base

  include ScriptHelper
  include PrivateUrl # gives private_url?

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
    'budget_dynamic_query',
    'spend_dynamic_query',
    'funding_source_query'
  ]

  ### Attributes
  attr_accessible :key, :csv, :data_request_id
  attr_accessor :report, :raw_csv, :temp_file_name, :zip_file_name, :unzip_file_name

  ### Attachments
  has_attached_file :csv, Settings.paperclip_report.to_options

  ### Validations
  validates_presence_of :key, :data_request_id
  validates_uniqueness_of :key, :scope => :data_request_id
  validates_inclusion_of :key, :in => REPORTS

  def private_csv_url
    if private_url?
      csv.expiring_url(3600)
    else
      csv.url
    end
  end

  def generate_report
    create_report
  end

  def generate_report_for_download(user)
    create_report
    Notifier.deliver_report_download_notification(user, self)
  end
  handle_asynchronously :generate_report_for_download

  protected

    def run_report
      self.report =
        case key
        when 'activity_overview'
          Reports::ActivityOverview.new(data_request)
        when 'budget_implementer_purpose'
          Reports::ClassificationSplit.new(data_request, :budget, :purpose)
        when 'budget_implementer_input'
          Reports::ClassificationSplit.new(data_request, :budget, :input)
        when 'budget_implementer_location'
          Reports::ClassificationSplit.new(data_request, :budget, :location)
        when 'spend_implementer_purpose'
          Reports::ClassificationSplit.new(data_request, :spend, :purpose)
        when 'spend_implementer_input'
          Reports::ClassificationSplit.new(data_request, :spend, :input)
        when 'spend_implementer_location'
          Reports::ClassificationSplit.new(data_request, :spend, :location)
        when 'budget_implementer_funding_source'
          Reports::FundingSourceSplit.new(data_request, :budget)
        when 'spend_implementer_funding_source'
          Reports::FundingSourceSplit.new(data_request, :spend)
        when 'budget_implementer_target'
          Reports::Targets.new(data_request, :budget)
        when 'spend_implementer_target'
          Reports::Targets.new(data_request, :spend)
        when 'budget_implementer_output'
          Reports::Outputs.new(data_request, :budget)
        when 'spend_implementer_output'
          Reports::Outputs.new(data_request, :spend)
        when 'budget_implementer_beneficiary'
          Reports::Beneficiaries.new(data_request, :budget)
        when 'spend_implementer_beneficiary'
          Reports::Beneficiaries.new(data_request, :spend)
        when 'budget_dynamic_query'
          Reports::DynamicQuery.new(data_request, :budget)
        when 'spend_dynamic_query'
          Reports::DynamicQuery.new(data_request, :spend)
        when 'funding_source_query'
          Reports::FundingSource.new(data_request)
        else
          raise "Invalid report request '#{self.key}'"
        end
      self.raw_csv = report.csv #force the report to run.
    end

    def create_tmp_csv
      self.temp_file_name = "#{RAILS_ROOT}/tmp/#{self.key}_#{data_request_id}_#{get_date()}.csv"
      # Convert to Windows-1252 encoding because Excel <2007 does not
      # recognize UTF8 encoded files.
      # self.raw_csv = Iconv.conv("WINDOWS-1252//IGNORE", "UTF-8", self.raw_csv)
      self.raw_csv = self.raw_csv
      File.open(self.temp_file_name, 'w')  {|f| f.write(self.raw_csv)}
    end

    def zip_file
      self.zip_file_name = self.temp_file_name + ".zip"
      cmd = "zip -j -9 #{self.zip_file_name} #{self.temp_file_name}"
      output = %x(#{cmd})
    end

    def self.unzip_csv(file_path)
      cmd = "unzip -p #{file_path}"
      output = %x(#{cmd})
    end

    def attach_zip_file
      self.csv = File.new(self.zip_file_name, 'r')
    end

    def cleanup_temp_files
      File.delete self.temp_file_name if self.temp_file_name
      File.delete self.zip_file_name if self.zip_file_name
    end

    def create_report
      run_report
      create_tmp_csv
      zip_file
      attach_zip_file
      self.save
      cleanup_temp_files
    end
end

# == Schema Information
#
# Table name: reports
#
#  id                         :integer         not null, primary key
#  key                        :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  csv_file_name              :string(255)
#  csv_content_type           :string(255)
#  csv_file_size              :integer
#  csv_updated_at             :datetime
#  data_request_id            :integer
#

