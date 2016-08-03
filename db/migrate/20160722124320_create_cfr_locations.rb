class CreateCfrLocations < ActiveRecord::Migration
  def change
    create_table :cfr_locations do |t|
      t.belongs_to  :cfr_record,        index: true, foreign_key: true
      t.belongs_to  :cfr_location_type, index: true, foreign_key: true
      t.boolean     :is_main_location,  default: false, null: false
      t.string      :file_name,         limit: MAX_LENGTH_OF_STRING
      t.string      :doc_code,          limit: MAX_LENGTH_OF_DOC_ID
      t.string      :doc_version,       limit: MAX_LENGTH_OF_DOC_VERSION
      t.text        :uri,               limit: MAX_LENGTH_OF_URI    

      t.timestamps null: false
    end
  end
end
