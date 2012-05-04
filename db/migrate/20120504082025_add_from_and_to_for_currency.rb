class AddFromAndToForCurrency < ActiveRecord::Migration
  def self.up
    add_column :currencies, :from, :string
    add_column :currencies, :to, :string

    Currency.reset_column_information
    Currency.all.each do |currency|
      splits = currency[:conversion].split('_TO_')
      currency.from = splits.first
      currency.to   = splits.last
      currency.save!
    end

    remove_column :currencies, :conversion
  end

  def self.down
    add_column :currencies, :conversion, :string
    remove_column :currencies, :from
    remove_column :currencies, :to
  end
end
