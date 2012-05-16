class Location < Code
  has_and_belongs_to_many :activities

  alias_attribute :name, :short_display

  named_scope :national_level, { :conditions => "lower(codes.short_display) = 'national level'" }
  named_scope :without_national_level, { :conditions => "lower(codes.short_display) != 'national level'" }
  named_scope :sorted, { :order => "codes.short_display" }
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

