class CreateDbChangeRequests < ActiveRecord::Migration
  def change
    create_table :db_change_requests do |t|
      t.belongs_to :requesting_account,  index: :true
      t.belongs_to :responsible_account, index: :true
      t.integer :feature_id
      t.string  :detail, limit: MAX_LENGTH_OF_LABEL
      t.string  :action, limit: MAX_LENGTH_OF_CODE 
      t.integer :status, default: 0
      t.string  :uri
      t.text    :request_text

      t.timestamps null: false
    end
    add_foreign_key :db_change_requests, :accounts, column: :requesting_account_id
    add_foreign_key :db_change_requests, :accounts, column: :responsible_account_id
  end
end
