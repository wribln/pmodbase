class CreateNetworkStations < ActiveRecord::Migration[5.1]
  def change
    create_table :network_stations do |t|
      t.string      :code,      length: MAX_LENGTH_OF_CODE, null: false
      t.string      :alt_code,  length: MAX_LENGTH_OF_CODE
      t.string      :curr_name, length: MAX_LENGTH_OF_LABEL
      t.string      :prev_name, length: MAX_LENGTH_OF_LABEL
      t.boolean     :transfer,  null: false, default: false
      t.string      :note,      length: MAX_LENGTH_OF_DESCRIPTION

      t.timestamps null: false
    end
  end
end
