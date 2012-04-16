class AddVisibilityMaskToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :visibility, :string
  end

  def self.down
    remove_column :documents, :visibility
  end
end
