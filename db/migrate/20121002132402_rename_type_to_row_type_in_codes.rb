class RenameTypeToRowTypeInCodes < ActiveRecord::Migration
  def change
    rename_column :codes, :type, :raw_type
  end
end
