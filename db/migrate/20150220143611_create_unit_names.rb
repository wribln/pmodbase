class CreateUnitNames < ActiveRecord::Migration[5.1]
  def change
    create_table :unit_names do |t|
      t.string :code,  limit: MAX_LENGTH_OF_CODE,  null: false, index: true, unique: true
      t.string :label, limit: MAX_LENGTH_OF_LABEL, null: false

      t.timestamps null: false
    end
  end
end
