class CreateNetworkStops < ActiveRecord::Migration[5.1]
  def change
    create_table :network_stops do |t|
      t.belongs_to  :network_station, foreign_key: true, null: false, index: true
      t.belongs_to  :network_line,    foreign_key: true, null: false, index: true
      t.belongs_to  :location_code,   foreign_key: true
      t.integer     :stop_no
      t.string      :code,  length: MAX_LENGTH_OF_CODE
      t.string      :note,  length: MAX_LENGTH_OF_DESCRIPTION

      t.timestamps null: false
    end
    add_index :network_stops, [ :network_line_id, :stop_no ]
  end
end
