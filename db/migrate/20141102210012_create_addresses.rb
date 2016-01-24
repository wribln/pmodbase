class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :label,          limit: MAX_LENGTH_OF_LABEL, null: false, index: true, unique: true
      t.string :street_address, limit: MAX_LENGTH_OF_ADDRESS
      t.string :postal_address, limit: MAX_LENGTH_OF_ADDRESS

      t.timestamps null: false
    end
  end
end
