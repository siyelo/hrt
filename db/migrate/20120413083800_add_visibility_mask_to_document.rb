class AddVisibilityMaskToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :visibility, :string
    add_column :documents, :description, :text
  end

  def self.down
    remove_column :documents, :visibility
    remove_column :documents, :description
  end
end
