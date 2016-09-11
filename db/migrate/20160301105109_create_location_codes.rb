class CreateLocationCodes < ActiveRecord::Migration
  def change
    create_table :location_codes do |t|
      t.string  :code,          limit: MAX_LENGTH_OF_CODE, null: false, index: true
      t.string  :label,         limit: MAX_LENGTH_OF_LABEL, null: false
      t.integer :loc_type,      null: false, default: 2
      t.decimal :center_point,  precision: 10, scale: 3
      t.decimal :start_point,   precision: 10, scale: 3
      t.decimal :end_point,     precision: 10, scale: 3
      t.decimal :length
      t.references :part_of,    index: true
      t.string  :remarks,       limit: MAX_LENGTH_OF_DESCRIPTION

      t.timestamps null: false
    end
  end
end
