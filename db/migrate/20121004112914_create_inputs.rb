class CreateInputs < ActiveRecord::Migration
  def change
    create_table :inputs do |t|
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :name
      t.text :description
      t.string :external_id
      t.integer :version

      t.timestamps
    end
  end
end
