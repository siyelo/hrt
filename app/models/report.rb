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
  attr_accessible :key, :attachment, :data_request_id
  attr_accessor :temp_file_name, :zip_file_name

  ### Attachments
  has_attached_file :attachment, Settings.paperclip_report.to_options

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
    Notifier.deliver_report_download_notification(user, self)
  end
  handle_asynchronously :generate_report_for_download

  protected

    def report
      case key
      when 'activity_overview'
        Reports::ActivityOverview.new(data_request, 'xls')
      when 'budget_implementer_purpose'
        Reports::ClassificationSplit.new(data_request, :budget, :purpose, 'xls')
      when 'budget_implementer_input'
        Reports::ClassificationSplit.new(data_request, :budget, :input, 'xls')
      when 'budget_implementer_location'
        Reports::ClassificationSplit.new(data_request, :budget, :location, 'xls')
      when 'spend_implementer_purpose'
        Reports::ClassificationSplit.new(data_request, :spend, :purpose, 'xls')
      when 'spend_implementer_input'
        Reports::ClassificationSplit.new(data_request, :spend, :input, 'xls')
      when 'spend_implementer_location'
        Reports::ClassificationSplit.new(data_request, :spend, :location, 'xls')
      when 'budget_implementer_funding_source'
        Reports::FundingSourceSplit.new(data_request, :budget, 'xls')
      when 'spend_implementer_funding_source'
        Reports::FundingSourceSplit.new(data_request, :spend, 'xls')
      when 'budget_implementer_target'
        Reports::Targets.new(data_request, :budget, 'xls')
      when 'spend_implementer_target'
        Reports::Targets.new(data_request, :spend, 'xls')
      when 'budget_implementer_output'
        Reports::Outputs.new(data_request, :budget, 'xls')
      when 'spend_implementer_output'
        Reports::Outputs.new(data_request, :spend, 'xls')
      when 'budget_implementer_beneficiary'
        Reports::Beneficiaries.new(data_request, :budget, 'xls')
      when 'spend_implementer_beneficiary'
        Reports::Beneficiaries.new(data_request, :spend, 'xls')
      when 'budget_dynamic_query'
        Reports::DynamicQuery.new(data_request, :budget, 'xml')
      when 'spend_dynamic_query'
        Reports::DynamicQuery.new(data_request, :spend, 'xml')
      when 'funding_source_query'
        Reports::FundingSource.new(data_request, 'xls')
      else
        raise "Invalid report request '#{self.key}'"
      end
    end

    def create_tmp_file
      report.data do |content, filetype, mimetype|
        self.temp_file_name = "#{RAILS_ROOT}/tmp/#{key}_#{data_request_id}_#{get_date()}.#{filetype}"
        File.open(temp_file_name, 'w')  {|f| f.write(content)}
      end
    end

    def zip_file
      self.zip_file_name = self.temp_file_name + ".zip"
      cmd = "zip -j -9 #{self.zip_file_name} #{self.temp_file_name}"
      output = %x(#{cmd})
    end

    def self.unzip_file(file_path)
      cmd = "unzip -p #{file_path}"
      output = %x(#{cmd})
    end

    def attach_zip_file
      self.attachment = File.new(self.zip_file_name, 'r')
    end

    def cleanup_temp_files
      File.delete self.temp_file_name if self.temp_file_name
      File.delete self.zip_file_name if self.zip_file_name
    end

    def create_report
      create_tmp_file
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

