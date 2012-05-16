class RenameCsvToAttachmentForReports < ActiveRecord::Migration
  def self.up
    rename_column :reports, :csv_file_name, :attachment_file_name
    rename_column :reports, :csv_content_type, :attachment_content_type
    rename_column :reports, :csv_file_size, :attachment_file_size
    rename_column :reports, :csv_updated_at, :attachment_updated_at
  end

  def self.down
    rename_column :reports, :attachment_file_name, :csv_file_name
    rename_column :reports, :attachment_content_type, :csv_content_type
    rename_column :reports, :attachment_file_size, :csv_file_size
    rename_column :reports, :attachment_updated_at, :csv_updated_at
  end
end
