class CreateNetworkLines < ActiveRecord::Migration
  def change
    create_table :network_lines do |t|
      t.string      :code,  length: MAX_LENGTH_OF_CODE,   null: false
      t.string      :label, length: MAX_LENGTH_OF_LABEL,  null: false
      t.integer     :seqno, null: false, default: 0
      t.string      :note,  length: MAX_LENGTH_OF_NOTE
      t.belongs_to  :location_code, foreign_key: true

      t.timestamps null: false
    end
  end
end
