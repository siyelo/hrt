class CreatePurposes < ActiveRecord::Migration
  def change
    create_table :purposes do |t|
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :name
      t.text :description
      t.integer :version
      t.string :official_name
      t.string :sub_account
      t.string :mtef_code
      t.string :nsp_code
      t.string :nasa_code
      t.string :nha_code
      t.string :hssp2_stratprog_val
      t.string :hssp2_stratobj_val

      t.timestamps
    end
  end
end
