class CreateA8Codes < ActiveRecord::Migration
  def change
    create_table :a8_codes do |t|
      t.string  :code,     length: MAX_LENGTH_OF_CODE,  null: false, index: true
      t.string  :label,    length: MAX_LENGTH_OF_LABEL, null: false
      t.boolean :active,   null: false, default: true
      t.boolean :master,   null: false, default: true
      t.string  :mapping,  length: MAX_LENGTH_OF_CODE

      t.timestamps null: false
    end
  end
end
