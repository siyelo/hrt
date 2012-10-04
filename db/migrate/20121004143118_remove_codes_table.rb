class RemoveCodesTable < ActiveRecord::Migration
  def up
    drop_table :codes
  end

  def down
    create_table "codes", :force => true do |t|
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.string   "short_display"
      t.string   "long_display"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "type"
      t.string   "external_id"
      t.string   "hssp2_stratprog_val"
      t.string   "hssp2_stratobj_val"
      t.string   "official_name"
      t.string   "sub_account"
      t.string   "nha_code"
      t.string   "nasa_code"
      t.integer  "version"
      t.string   "mtef_code"
      t.string   "nsp_code"
    end
  end
end
