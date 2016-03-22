class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string      :code,      length: MAX_LENGTH_OF_CODE
      t.string      :label,     length: MAX_LENGTH_OF_LABEL
      t.belongs_to  :feature,   foreign_key: true
      t.string      :sort_code, length: MAX_LENGTH_OF_CODE
      t.integer     :seqno,     default: 0

      t.timestamps null: false
    end
    add_index :hashtags, [ :feature_id, :code ], unique: true
  end
end
