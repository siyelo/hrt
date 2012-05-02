class RemoveFormattedCsvFromReports < ActiveRecord::Migration
  def self.up
    remove_column :reports, :formatted_csv_file_name
    remove_column :reports, :formatted_csv_content_type
    remove_column :reports, :formatted_csv_file_size
    remove_column :reports, :formatted_csv_updated_at
  end

  def self.down
    add_column :reports, :formatted_csv_file_name,    :string
    add_column :reports, :formatted_csv_content_type, :string
    add_column :reports, :formatted_csv_file_size,    :integer
    add_column :reports, :formatted_csv_updated_at,   :datetime
  end
end
