class Purpose < Code
end

# == Schema Information
#
# Table name: codes
#
#  id                  :integer         not null, primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :datetime
#  updated_at          :datetime
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

