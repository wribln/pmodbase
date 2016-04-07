class CreateTiaLists < ActiveRecord::Migration
  def change
    create_table :tia_lists do |t|
      t.integer :owner_account_id, null: false, index: true
      t.integer :deputy_account_id, index: true
      t.string  :code, length: MAX_LENGTH_OF_CODE
      t.string  :label, length: MAX_LENGTH_OF_LABEL

      t.timestamps null: false
    end
  end
end
