class CreateRegionNames < ActiveRecord::Migration
  def change
    create_table :region_names do |t|
      t.belongs_to  :country_name, null: false
      t.string      :code,  limit: MAX_LENGTH_OF_CODE,  null: false
      t.string      :label, limit: MAX_LENGTH_OF_LABEL, null: false

      t.timestamps null: false
    end
    add_index :region_names, [ :country_name_id, :code ], unique: true, name: 'cr_index'
  end
end
