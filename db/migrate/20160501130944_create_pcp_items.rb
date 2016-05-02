class CreatePcpItems < ActiveRecord::Migration
  def change
    create_table :pcp_items do |t|
      t.belongs_to  :pcp_subject, index: true, foreign_key: true
      t.belongs_to  :pcp_step,    index: true, foreign_key: true
      t.integer     :seqno,       null: false
      t.string      :reference,                 limit: MAX_LENGTH_OF_NOTE
      t.string      :description, null: false,  limit: MAX_LENGTH_OF_DESCRIPTION
      t.integer     :item_status, default: 0

      t.timestamps null: false
    end
    add_index :pcp_items, [ :pcp_subject_id, :seqno ], name: 'pcp_items_index'
  end
end
