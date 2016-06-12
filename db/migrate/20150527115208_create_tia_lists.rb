class CreateTiaLists < ActiveRecord::Migration
  def change
    create_table :tia_lists do |t|
      t.integer :owner_account_id,  index: true, null: false 
      t.integer :deputy_account_id, index: true
      t.string  :code, length: MAX_LENGTH_OF_CODE
      t.string  :label, length: MAX_LENGTH_OF_LABEL

      t.timestamps null: false
    end
    add_foreign_key :tia_lists, :accounts, column: :owner_account_id
    add_foreign_key :tia_lists, :accounts, column: :deputy_account_id
  end
end
