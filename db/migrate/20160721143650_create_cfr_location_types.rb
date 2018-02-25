class CreateCfrLocationTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :cfr_location_types do |t|
      t.string  :label,        limit: MAX_LENGTH_OF_LABEL, null: false
      t.integer :location_type, default: 0, null: false
      t.string  :path_prefix,  limit: MAX_LENGTH_OF_STRING
      t.string  :concat_char,  limit: MAX_LENGTH_OF_CODE
      t.boolean :project_dms,   default: false
      t.string  :note,         limit: MAX_LENGTH_OF_NOTE

      t.timestamps null: false
    end
  end
end
