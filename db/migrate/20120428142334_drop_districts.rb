class DropDistricts < ActiveRecord::Migration
  def self.up
    drop_table :districts
  end

  def self.down
    create_table :districts do |t|
      t.string :name
      t.integer :population
      t.integer :old_location_id

      t.timestamps
    end
  end

end
