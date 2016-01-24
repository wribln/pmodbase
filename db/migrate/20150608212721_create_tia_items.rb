class CreateTiaItems < ActiveRecord::Migration
  def change
    create_table :tia_items do |t|
      t.belongs_to  :tia_list,  null: false, index: true
      t.belongs_to  :account,                index: true
      t.integer     :seq_no,  default: 1
      t.string      :description, null: false, length: MAX_LENGTH_OF_DESCRIPTION
      t.string      :comment, length: MAX_LENGTH_OF_DESCRIPTION
      t.integer     :prio,    default: 0
      t.integer     :status,  default: 0
      t.date        :due_date
      t.boolean     :archived, null: false, default: false

      t.timestamps null: false
    end
    add_index :tia_items, [ :tia_list_id, :seq_no ], unique: true, name: 'tia_list_items_index'
  end
end
