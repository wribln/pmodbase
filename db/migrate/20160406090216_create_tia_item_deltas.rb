class CreateTiaItemDeltas < ActiveRecord::Migration
  def change
    create_table :tia_item_deltas do |t|
      t.belongs_to  :tia_item, null: false, index: true, foreign_key: :true
      t.text        :delta_hash

      t.timestamps null: false
    end
    add_index :tia_item_deltas, [ :tia_item_id, :created_at ], order: { created_at: :desc }
  end
end
