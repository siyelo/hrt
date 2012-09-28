class AddVersionToCodes < ActiveRecord::Migration

  def change
    add_column :codes, :version, :integer

    Code.reset_column_information
    Code.all.each do |code|
      code.version = 1
      code.save!
    end
  end
end
