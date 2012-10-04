class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  acts_as_nested_set
end

class LoadNewCodes < ActiveRecord::Migration
  def up
    Input.reset_column_information
    load 'db/seed_files/inputs_v2.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
