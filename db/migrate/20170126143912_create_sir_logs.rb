class CreateSirLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :sir_logs do |t|
      t.integer :owner_account_id,  index: true,  null: false 
      t.integer :deputy_account_id, index: true
      t.string  :code,              length: MAX_LENGTH_OF_CODE
      t.string  :label,             length: MAX_LENGTH_OF_LABEL
      t.boolean :archived,                        null: false, default: false

      t.timestamps null: false
    end
    add_foreign_key :sir_logs, :accounts, column: :owner_account_id
    add_foreign_key :sir_logs, :accounts, column: :deputy_account_id
  end
end
