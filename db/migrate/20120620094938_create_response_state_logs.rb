class CreateResponseStateLogs < ActiveRecord::Migration
  def change
    create_table :response_state_logs do |t|
      t.references :data_response
      t.references :user
      t.timestamps
    end
  end
end
