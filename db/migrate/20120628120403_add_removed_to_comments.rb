class AddRemovedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :removed, :boolean, default: false
  end
end
