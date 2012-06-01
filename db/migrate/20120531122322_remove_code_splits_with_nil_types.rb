class RemoveCodeSplitsWithNilTypes < ActiveRecord::Migration
  def self.up
    cs = CodeSplit.find(:all, :conditions => {:type => nil})
    total = cs.count
    count = 0
    cs.each do |split|
      split.destroy
      count += 1
      p "Removing code splits with nil type #{count}/#{total}"
    end
  end

  def self.down
    p "IRREVESIBLE MIGRATION"
  end
end
