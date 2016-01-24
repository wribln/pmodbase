class CreateDbChangeRequests < ActiveRecord::Migration
  def change
    create_table :db_change_requests do |t|
      t.integer :requesting_account_id
      t.integer :responsible_account_id
      t.integer :feature_id
      t.string  :detail, limit: MAX_LENGTH_OF_LABEL
      t.string  :action, limit: MAX_LENGTH_OF_CODE 
      t.integer :status, default: 0
      t.string  :uri
      t.text    :request_text

      t.timestamps null: false
    end
  end
end
