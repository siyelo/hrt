class AddCurrenciesToSplits < ActiveRecord::Migration
  def self.up
    add_column :implementer_splits, :currency, :string
    ImplementerSplit.reset_column_information
    is = ImplementerSplit.all
    count = is.count
    i = 0
    is.each do |split|
      i += 1
      puts "Adding currency to implementer_splits #{ i }/#{ count }"
      split.currency = split.activity.currency
      split.save(false)
    end
  end

  def self.down
    remove_column :implementer_splits, :currency
  end
end
