class RemoveNonreportingReponses < ActiveRecord::Migration
  def self.up
  load 'db/fixes/20120424_remove_dead_responses.rb'
  end

  def self.down
    puts 'irreversible'
  end
end
