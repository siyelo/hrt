class AddAttachmentWorkplanToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :workplan_file_name, :string
    add_column :users, :workplan_content_type, :string
    add_column :users, :workplan_file_size, :integer
    add_column :users, :workplan_updated_at, :datetime
  end

  def self.down
    remove_column :users, :workplan_file_name
    remove_column :users, :workplan_content_type
    remove_column :users, :workplan_file_size
    remove_column :users, :workplan_updated_at
  end
end
