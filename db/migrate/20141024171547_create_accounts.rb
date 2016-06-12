class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string      :name, limit: MAX_LENGTH_OF_ACCOUNT_NAME
      t.string      :password_digest
      t.boolean     :active,          null: false,  default: true,  index: :true
      t.boolean     :keep_base_open,  null: false,  default: false
      t.belongs_to  :person,          null: false, index: :true

      t.timestamps null: false
    end
  end
end
