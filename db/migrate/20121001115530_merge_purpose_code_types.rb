class MergePurposeCodeTypes < ActiveRecord::Migration
  def up
    Code.update_all({:type => "Purpose"}, {:type => %w[Mtef Nha Nasa Nsp]})
  end

  def down
    puts 'irreversible migration'
  end
end
