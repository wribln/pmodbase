class CreateCfrRelations < ActiveRecord::Migration
  def change
    create_table :cfr_relations do |t|
      t.belongs_to :src_record,       index: true, foreign_key: true
      t.belongs_to :dst_record,       index: true, foreign_key: true
      t.belongs_to :cfr_relationship, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
