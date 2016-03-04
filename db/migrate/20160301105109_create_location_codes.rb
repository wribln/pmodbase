class CreateLocationCodes < ActiveRecord::Migration
  def change
    create_table :location_codes do |t|
      t.string  :code,          limit: MAX_LENGTH_OF_CODE, null: false, index: true
      t.string  :label,         limit: MAX_LENGTH_OF_LABEL, null: false
      t.integer :loc_type,      null: false, default: 2
      t.integer :center_point
      t.integer :start_point
      t.integer :end_point
      t.integer :length
      t.string  :note,          limit: MAX_LENGTH_OF_NOTE

      t.timestamps null: false
    end
  end
end
