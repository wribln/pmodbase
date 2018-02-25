class CreateCfrRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :cfr_relationships do |t|
      t.integer     :rs_group, default: 2
      t.string      :label,                 limit: MAX_LENGTH_OF_LABEL
      t.references  :reverse_rs
      t.boolean     :leading,   default: false

      t.timestamps null: false
    end
  end
end
