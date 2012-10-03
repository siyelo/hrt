class MergePurposeCodeTypes < ActiveRecord::Migration
  def up
    Code.reset_column_information
    Code.update_all({:type => "Purpose"}, {:type => %w[Mtef Nha Nasa Nsp]})
  end

  def down
    puts 'irreversible migration'
  end
end
