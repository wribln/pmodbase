class CreateCfrRelations < ActiveRecord::Migration
  def change
    create_table :cfr_relations do |t|
      t.belongs_to :src_record,       index: true
      t.belongs_to :dst_record,       index: true
      t.belongs_to :cfr_relationship, index: true, foreign_key: true
      t.timestamps null: false
    end
  add_foreign_key :cfr_relations, :cfr_records, column: :src_record_id
  add_foreign_key :cfr_relations, :cfr_records, column: :dst_record_id
  end
end
