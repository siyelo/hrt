class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  acts_as_nested_set
end

class MergePurposeCodeTypes < ActiveRecord::Migration
  def up
    Code.reset_column_information
    Code.update_all({:type => "Purpose"}, {:type => %w[Mtef Nha Nasa Nsp]})
  end

  def down
    puts 'irreversible migration'
  end
end
