class Currency < ActiveRecord::Base

  ### Attributes
  attr_accessible :to, :from, :rate

  ### Validations
  validates_uniqueness_of :to, :scope => :from
  validates_uniqueness_of :from, :scope => :to
  validates_presence_of :from
  validates_presence_of :to
  validates_numericality_of :rate

  ### Callbacks
  after_save :reload_currencies

  ### Named scopes
  named_scope :sorted, {:order => 'updated_at DESC'}

  def conversion
    "#{from}_TO_#{to}"
  end

  ### Class Methods
  def self.currency_rates
    currencies = {}
    Currency.all.each do |currency|
      currencies[currency.conversion] = currency.rate
    end
    currencies
  end

  private

  def reload_currencies
    Money.default_bank.import_rates(:yaml, Currency.currency_rates.to_yaml)
  end
end

# == Schema Information
#
# Table name: currencies
#
#  id         :integer         not null, primary key
#  rate       :float
#  created_at :datetime
#  updated_at :datetime
#  from       :string(255)
#  to         :string(255)
#

