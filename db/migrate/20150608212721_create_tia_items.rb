class CreateTiaItems < ActiveRecord::Migration
  def change
    create_table :tia_items do |t|
      t.belongs_to  :tia_list,  null: false, foreign_key: true
      t.belongs_to  :account,                foreign_key: true, index: true
      t.integer     :seqno,   default: 1
      t.string      :description, null: false,  length: MAX_LENGTH_OF_DESCRIPTION
      t.string      :comment,                   length: MAX_LENGTH_OF_DESCRIPTION
      t.integer     :prio,    default: 0
      t.integer     :status,  default: 0
      t.date        :due_date
      t.boolean     :archived, null: false, default: false

      t.timestamps null: false
    end
    add_index :tia_items, [ :tia_list_id, :seqno ], unique: true, name: 'tia_list_items_index'
  end
end
